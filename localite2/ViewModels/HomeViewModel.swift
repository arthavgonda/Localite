import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var userName: String
    @Published private(set) var locationLabel: String
    @Published private(set) var heroProduct: Product
    @Published private(set) var categories: [CategoryItem]
    @Published private(set) var localPicks: [Product]
    @Published var selectedTab: TabBarItemKind = .home

    @Published private(set) var mode: AppMode = .exploring
    @Published private(set) var journeyInfo: JourneyInfo?
    @Published private(set) var displayedDialMinutes: Int = 0

    @Published var isShowingPNREntry: Bool = false
    @Published var pnrInput: String = ""
    @Published private(set) var isLookingUpPNR: Bool = false
    @Published var pnrErrorMessage: String?
    @Published var scrollOffset: CGFloat = 0

    let curatedRegionsCount: Int = 4

    private let lookupService: PNRLookupServicing
    private let persistenceStore: JourneyPersistenceStore
    private var activePNR: String?

    private var lookupTask: Task<Void, Never>?
    private var countUpTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    private var restoreTask: Task<Void, Never>?

    init(
        userName: String = "Parth",
        locationLabel: String = "Connaught Place, Delhi",
        heroProduct: Product = .heroSample,
        categories: [CategoryItem] = CategoryItem.sample,
        localPicks: [Product] = Product.localPicksSample,
        lookupService: PNRLookupServicing = MockPNRLookupService(),
        persistenceStore: JourneyPersistenceStore = JourneyPersistenceStore()
    ) {
        self.userName = userName
        self.locationLabel = locationLabel
        self.heroProduct = heroProduct
        self.categories = categories
        self.localPicks = localPicks
        self.lookupService = lookupService
        self.persistenceStore = persistenceStore

        restoreTask = Task { [weak self] in
            await self?.restorePersistedJourney()
        }
    }

    deinit {
        lookupTask?.cancel()
        countUpTask?.cancel()
        countdownTask?.cancel()
        restoreTask?.cancel()
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning, \(userName)"
        case 12..<17: return "Good afternoon, \(userName)"
        default: return "Good evening, \(userName)"
        }
    }

    func presentPNREntry() {
        pnrErrorMessage = nil
        pnrInput = ""
        isShowingPNREntry = true
    }

    func dismissPNREntry() {
        lookupTask?.cancel()
        isLookingUpPNR = false
        isShowingPNREntry = false
    }

    func submitPNR() {
        guard let normalized = PNR.validate(pnrInput) else {
            pnrErrorMessage = PNRError.invalidFormat.errorDescription
            return
        }

        lookupTask?.cancel()
        pnrErrorMessage = nil
        isLookingUpPNR = true

        lookupTask = Task { [weak self] in
            guard let self else { return }
            do {
                let info = try await self.lookupService.lookup(pnr: normalized)
                guard !Task.isCancelled else { return }
                await self.beginJourney(pnr: normalized, info: info)
                self.isLookingUpPNR = false
                self.isShowingPNREntry = false
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.isLookingUpPNR = false
                self.pnrErrorMessage = (error as? PNRError)?.errorDescription ?? PNRError.network.errorDescription
            }
        }
    }

    func endJourney() {
        countdownTask?.cancel()
        countUpTask?.cancel()
        mode = .exploring
        journeyInfo = nil
        displayedDialMinutes = 0
        activePNR = nil

        Task { [persistenceStore] in
            await persistenceStore.clear()
        }
    }

    private func beginJourney(pnr: String, info: JourneyInfo) async {
        activePNR = pnr
        mode = .journey
        journeyInfo = info
        animateDialCountUp()
        startCountdown()
        await persistenceStore.save(ActiveJourney(pnr: pnr, journeyInfo: info, startedAt: Date()))
    }

    private func restorePersistedJourney() async {
        guard let saved = await persistenceStore.load(), saved.journeyInfo.minutesRemaining > 0 else {
            await persistenceStore.clear()
            return
        }
        activePNR = saved.pnr
        mode = .journey
        journeyInfo = saved.journeyInfo
        displayedDialMinutes = saved.journeyInfo.minutesRemaining
        startCountdown()
    }

    private func animateDialCountUp() {
        countUpTask?.cancel()
        displayedDialMinutes = 0
        let target = journeyInfo?.minutesRemaining ?? 0
        countUpTask = Task { [weak self] in
            guard let self else { return }
            for value in 0...target {
                if Task.isCancelled { return }
                self.displayedDialMinutes = value
                try? await Task.sleep(nanoseconds: 45_000_000)
            }
        }
    }

    private func startCountdown() {
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            while true {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                guard let self, !Task.isCancelled else { return }
                await self.tickCountdown()
            }
        }
    }

    private func tickCountdown() async {
        guard var info = journeyInfo, info.minutesRemaining > 0 else { return }
        info.minutesRemaining -= 1
        journeyInfo = info
        displayedDialMinutes = info.minutesRemaining

        if info.minutesRemaining <= 0 {
            endJourney()
        } else if let activePNR {
            await persistenceStore.save(ActiveJourney(pnr: activePNR, journeyInfo: info, startedAt: Date()))
        }
    }
}
