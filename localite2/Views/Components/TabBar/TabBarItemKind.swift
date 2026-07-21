import Foundation

enum TabBarItemKind: String, CaseIterable, Identifiable {
    case home, explore, addJourney, cart, profile

    var id: String { rawValue }

    var title: String? {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .addJourney: return nil
        case .cart: return "Cart"
        case .profile: return "Profile"
        }
    }

    var symbolName: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "magnifyingglass"
        case .addJourney: return "ticket.fill"
        case .cart: return "cart.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}
