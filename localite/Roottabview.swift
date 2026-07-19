import SwiftUI
import MapKit

struct RemoteImage: View {
    let seed: String
    var width: Int = 600
    var height: Int = 400

    @StateObject private var loader = ImageLoader()

    private var localImage: UIImage? {
        UIImage(named: seed)
    }

    private var url: URL? {
        URL(string: "https://picsum.photos/seed/\(seed)/\(width)/\(height)")
    }

    var body: some View {
        ZStack {
            if let localImage {
                Image(uiImage: localImage)
                    .resizable()
            } else {
                switch loader.state {
                case .loaded:
                    if let uiImage = loader.image {
                        Image(uiImage: uiImage)
                            .resizable()
                    }
                case .failed:
                    Color.black.opacity(0.06)
                    Image(systemName: "photo")
                        .foregroundStyle(.tertiary)
                case .idle, .loading:
                    Color.black.opacity(0.06)
                    ProgressView()
                }
            }
        }
        .task(id: url) {
            guard localImage == nil else { return }
            loader.load(url: url)
        }
    }
}

enum AppRoute: Hashable {
    case explore
}

struct RootTabView: View {
    @StateObject private var nav = AppNavigation()
    @StateObject private var cart = CartStore()
    @StateObject private var exploreViewModel = ExploreViewModel()
    @StateObject private var locationStore = LocationStore()

    @Namespace private var heroNamespace
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        path.append(AppRoute.explore)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "train.side.rear.car")
                            Text("Rail Local")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 14)
                        .background(LocaliteTheme.ink, in: Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .explore:
                        exploreDestination
                    }
                }
        }
        .environmentObject(nav)
        .environmentObject(cart)
        .environmentObject(locationStore)
        .environment(\.heroNamespace, heroNamespace)
        .overlay {
            if let product = nav.selectedProduct {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { closeDetail() }
                    .transition(.opacity)

                ProductDetailView(product: product, sourceID: nav.selectedSourceID, onClose: closeDetail)
                    .ignoresSafeArea()
                    .environmentObject(cart)
                    .environment(\.heroNamespace, heroNamespace)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }

    private var exploreDestination: some View {
        ExploreView(viewModel: exploreViewModel, onBack: goHome)
            .environmentObject(locationStore)
            .overlay(alignment: .topTrailing) {
                Button {
                    if let coord = locationStore.liveCoordinate ?? (locationStore.selected.isLive ? locationStore.selected.coordinate : nil) {
                        withAnimation {
                            exploreViewModel.position = .region(MKCoordinateRegion(
                                center: coord,
                                latitudinalMeters: 1000,
                                longitudinalMeters: 1000
                            ))
                        }
                    } else {
                        exploreViewModel.recenterOnUser()
                    }
                } label: {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LocaliteTheme.ink)
                        .frame(width: 44, height: 44)
                        .background(Color.white, in: Circle())
                        .overlay(Circle().strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5))
                        .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.top, 8)
            }
    }

    private func goHome() {
        exploreViewModel.goHome()
        path.removeLast()
    }

    private func closeDetail() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
            nav.selectedProduct = nil
            nav.selectedSourceID = nil
        }
    }
}

#Preview {
    RootTabView()
}
