import Foundation

enum AppMode: String, CaseIterable, Identifiable, Codable {
    case exploring
    case journey

    var id: String { rawValue }

    var label: String {
        switch self {
        case .exploring: return "Not travelling"
        case .journey: return "On a journey"
        }
    }
}

struct JourneyInfo: Equatable, Codable {
    let destinationStation: String
    let totalMinutes: Int
    var minutesRemaining: Int
    let stationsAlongRoute: Int
    let regionalSpecialtiesCount: Int

    var progress: Double {
        guard totalMinutes > 0 else { return 0 }
        return 1 - (Double(minutesRemaining) / Double(totalMinutes))
    }
}

#if DEBUG
extension JourneyInfo {
    static let sample = JourneyInfo(
        destinationStation: "Mathura",
        totalMinutes: 40,
        minutesRemaining: 22,
        stationsAlongRoute: 4,
        regionalSpecialtiesCount: 4
    )
}
#endif
