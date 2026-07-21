import Foundation

struct CategoryItem: Identifiable, Equatable {
    enum Kind: String {
        case fruit, vegetable, craft, textile

        var displayName: String {
            switch self {
            case .fruit: return "Fruits"
            case .vegetable: return "Vegetables"
            case .craft: return "Handicrafts"
            case .textile: return "Textiles"
            }
        }

        var symbolName: String {
            switch self {
            case .fruit: return "apple.logo"
            case .vegetable: return "leaf.fill"
            case .craft: return "hand.draw.fill"
            case .textile: return "line.3.horizontal"
            }
        }
    }

    let id: UUID = UUID()
    let kind: Kind
    let countLabel: String
}

#if DEBUG
extension CategoryItem {
    static let sample: [CategoryItem] = [
        CategoryItem(kind: .fruit, countLabel: "86 varieties"),
        CategoryItem(kind: .vegetable, countLabel: "64 varieties"),
        CategoryItem(kind: .craft, countLabel: "231 makers"),
        CategoryItem(kind: .textile, countLabel: "97 weaves")
    ]
}
#endif
