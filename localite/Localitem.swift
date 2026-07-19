import SwiftUI

enum LocalCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case handicrafts = "Handicrafts"

    var id: String { rawValue }

    static let browsable: [LocalCategory] = [.fruits, .vegetables, .handicrafts]

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .fruits: return "leaf.fill"
        case .vegetables: return "carrot.fill"
        case .handicrafts: return "hammer.fill"
        }
    }
}

struct Product: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let price: String
    let originalPrice: String?
    let imageSeed: String
    let discountPercent: Int?
    let category: LocalCategory
    let originVillage: String
    let rating: Double
    let ratingCount: String
    let etaText: String
    let discountBadge: String?
    let description: String
    let distance: String

    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}

struct SeasonalHighlight: Identifiable {
    var id: UUID { product.id }
    let badge: String
    let title: String
    let subtitle: String
    let imageSeed: String
    let category: LocalCategory
    let rating: Double
    let ratingCount: String
    let windowLabel: String
    let windowValue: String
    let priceLabel: String
    let priceValue: String
    let product: Product
}

enum LocalStore {
    static let products: [Product] = [
        Product(
            name: "Alphonso Mangoes",
            price: "₹180",
            originalPrice: "₹230",
            imageSeed: "mangoes",
            discountPercent: 22,
            category: .fruits,
            originVillage: "Malihabad, Uttar Pradesh",
            rating: 4.9,
            ratingCount: "1.2k",
            etaText: "20-30 min",
            discountBadge: "Up to 25% off mangoes this week",
            description: "Grown on a third-generation family orchard on the outskirts of the city, without cold storage. Everything is picked the same morning it's listed.",
            distance: "0.4 km"
        ),
        Product(
            name: "Kesar Mangoes",
            price: "₹150",
            originalPrice: nil,
            imageSeed: "kesar_mango",
            discountPercent: nil,
            category: .fruits,
            originVillage: "Malihabad, Uttar Pradesh",
            rating: 4.9,
            ratingCount: "1.2k",
            etaText: "20-30 min",
            discountBadge: nil,
            description: "Grown on a third-generation family orchard on the outskirts of the city, without cold storage. Everything is picked the same morning it's listed.",
            distance: "0.4 km"
        ),
        Product(
            name: "Raw Mango Pickle",
            price: "₹120",
            originalPrice: nil,
            imageSeed: "raw_mango_pickle",
            discountPercent: nil,
            category: .fruits,
            originVillage: "Malihabad, Uttar Pradesh",
            rating: 4.9,
            ratingCount: "1.2k",
            etaText: "20-30 min",
            discountBadge: nil,
            description: "Grown on a third-generation family orchard on the outskirts of the city, without cold storage. Everything is picked the same morning it's listed.",
            distance: "0.4 km"
        ),
        Product(
            name: "Shahi Lychee",
            price: "₹220",
            originalPrice: nil,
            imageSeed: "shahi-litchi",
            discountPercent: nil,
            category: .fruits,
            originVillage: "Muzaffarpur, Bihar",
            rating: 4.7,
            ratingCount: "540",
            etaText: "15-25 min",
            discountBadge: nil,
            description: "Small-batch shahi lychees with a delicate rose fragrance, hand-picked to preserve the thin, blushing skin.",
            distance: "0.8 km"
        ),
        Product(
            name: "Lychee Juice",
            price: "₹140",
            originalPrice: nil,
            imageSeed: "litchi_juice",
            discountPercent: nil,
            category: .fruits,
            originVillage: "Muzaffarpur, Bihar",
            rating: 4.7,
            ratingCount: "540",
            etaText: "15-25 min",
            discountBadge: nil,
            description: "Small-batch shahi lychees with a delicate rose fragrance, hand-picked to preserve the thin, blushing skin.",
            distance: "0.8 km"
        ),
        Product(
            name: "Kashmiri Apples",
            price: "₹160",
            originalPrice: "₹190",
            imageSeed: "kashmiri_apples",
            discountPercent: 16,
            category: .fruits,
            originVillage: "Shopian, Kashmir",
            rating: 4.8,
            ratingCount: "970",
            etaText: "25-35 min",
            discountBadge: "Weekend apple sale",
            description: "Crisp, cold-stored Kashmiri apples with a deep red blush, grown in the high altitude orchards of the Shopian valley.",
            distance: "2.0 km"
        ),
        Product(
            name: "Apple Cider",
            price: "₹130",
            originalPrice: nil,
            imageSeed: "apple_cider",
            discountPercent: nil,
            category: .fruits,
            originVillage: "Shopian, Kashmir",
            rating: 4.8,
            ratingCount: "970",
            etaText: "25-35 min",
            discountBadge: nil,
            description: "Crisp, cold-stored Kashmiri apples with a deep red blush, grown in the high altitude orchards of the Shopian valley.",
            distance: "2.0 km"
        ),
        Product(
            name: "Organic Spinach",
            price: "₹40",
            originalPrice: nil,
            imageSeed: "spinach-01",
            discountPercent: nil,
            category: .vegetables,
            originVillage: "Sonipat, Haryana",
            rating: 4.8,
            ratingCount: "690",
            etaText: "15-25 min",
            discountBadge: "Fresh greens, cut this morning",
            description: "A no-spray kitchen garden supplying leafy greens and seasonal vegetables, harvested at dawn and delivered the same day.",
            distance: "0.6 km"
        ),
        Product(
            name: "Farm Tomatoes",
            price: "₹60",
            originalPrice: "₹75",
            imageSeed: "tomato-01",
            discountPercent: 20,
            category: .vegetables,
            originVillage: "Sonipat, Haryana",
            rating: 4.8,
            ratingCount: "690",
            etaText: "15-25 min",
            discountBadge: nil,
            description: "A no-spray kitchen garden supplying leafy greens and seasonal vegetables, harvested at dawn and delivered the same day.",
            distance: "0.6 km"
        ),
        Product(
            name: "Toor Dal",
            price: "₹140",
            originalPrice: nil,
            imageSeed: "dal-01",
            discountPercent: nil,
            category: .vegetables,
            originVillage: "Sonipat, Haryana",
            rating: 4.8,
            ratingCount: "690",
            etaText: "15-25 min",
            discountBadge: nil,
            description: "A no-spray kitchen garden supplying leafy greens and seasonal vegetables, harvested at dawn and delivered the same day.",
            distance: "0.6 km"
        ),
        Product(
            name: "Yellow Moong Dal",
            price: "₹130",
            originalPrice: nil,
            imageSeed: "moong-01",
            discountPercent: nil,
            category: .vegetables,
            originVillage: "Ludhiana, Punjab",
            rating: 4.6,
            ratingCount: "410",
            etaText: "20-30 min",
            discountBadge: nil,
            description: "Sun-dried lentils sourced directly from Punjab mandis, paired with a rotating selection of crisp seasonal vegetables.",
            distance: "1.3 km"
        ),
        Product(
            name: "Fresh Okra",
            price: "₹35",
            originalPrice: nil,
            imageSeed: "okra-01",
            discountPercent: nil,
            category: .vegetables,
            originVillage: "Ludhiana, Punjab",
            rating: 4.6,
            ratingCount: "410",
            etaText: "20-30 min",
            discountBadge: nil,
            description: "Sun-dried lentils sourced directly from Punjab mandis, paired with a rotating selection of crisp seasonal vegetables.",
            distance: "1.3 km"
        ),
        Product(
            name: "Blue Pottery Bowl Set",
            price: "₹950",
            originalPrice: "₹1,120",
            imageSeed: "blue_pttoery_bowl_set",
            discountPercent: 15,
            category: .handicrafts,
            originVillage: "Jaipur, Rajasthan",
            rating: 4.8,
            ratingCount: "860",
            etaText: "30-40 min",
            discountBadge: "Festive season, 15% off pottery",
            description: "Hand-thrown blue pottery glazed with cobalt and quartz, fired in a wood kiln using techniques passed down since the Mughal era.",
            distance: "1.1 km"
        ),
        Product(
            name: "Hand-painted Vase",
            price: "₹1,200",
            originalPrice: nil,
            imageSeed: "hand_painted_vase",
            discountPercent: nil,
            category: .handicrafts,
            originVillage: "Jaipur, Rajasthan",
            rating: 4.8,
            ratingCount: "860",
            etaText: "30-40 min",
            discountBadge: nil,
            description: "Hand-thrown blue pottery glazed with cobalt and quartz, fired in a wood kiln using techniques passed down since the Mughal era.",
            distance: "1.1 km"
        ),
        Product(
            name: "Ceramic Coasters (Set of 4)",
            price: "₹450",
            originalPrice: nil,
            imageSeed: "ceramic_coaster",
            discountPercent: nil,
            category: .handicrafts,
            originVillage: "Jaipur, Rajasthan",
            rating: 4.8,
            ratingCount: "860",
            etaText: "30-40 min",
            discountBadge: nil,
            description: "Hand-thrown blue pottery glazed with cobalt and quartz, fired in a wood kiln using techniques passed down since the Mughal era.",
            distance: "1.1 km"
        ),
        Product(
            name: "Hand-loom Silk Stole",
            price: "₹1,450",
            originalPrice: nil,
            imageSeed: "handloom_silk_stole",
            discountPercent: nil,
            category: .handicrafts,
            originVillage: "Varanasi, Uttar Pradesh",
            rating: 5.0,
            ratingCount: "312",
            etaText: "40-50 min",
            discountBadge: nil,
            description: "Pure silk stoles woven on a traditional pit loom, with hand-tied zari borders that take nearly two days to complete.",
            distance: "2.3 km"
        ),
        Product(
            name: "Zari Border Dupatta",
            price: "₹1,900",
            originalPrice: "₹2,200",
            imageSeed: "zari_border_dupatta",
            discountPercent: 14,
            category: .handicrafts,
            originVillage: "Varanasi, Uttar Pradesh",
            rating: 5.0,
            ratingCount: "312",
            etaText: "40-50 min",
            discountBadge: nil,
            description: "Pure silk stoles woven on a traditional pit loom, with hand-tied zari borders that take nearly two days to complete.",
            distance: "2.3 km"
        ),
        Product(
            name: "Brass Diya Set (6 pcs)",
            price: "₹680",
            originalPrice: nil,
            imageSeed: "brass_diya_set",
            discountPercent: nil,
            category: .handicrafts,
            originVillage: "Moradabad, Uttar Pradesh",
            rating: 4.9,
            ratingCount: "410",
            etaText: "35-45 min",
            discountBadge: nil,
            description: "Hand-cast brass diyas with etched floral motifs, polished by hand and finished with a protective lacquer coat.",
            distance: "1.4 km"
        ),
        Product(
            name: "Engraved Brass Tray",
            price: "₹1,050",
            originalPrice: nil,
            imageSeed: "engraved_brass_tray",
            discountPercent: nil,
            category: .handicrafts,
            originVillage: "Moradabad, Uttar Pradesh",
            rating: 4.9,
            ratingCount: "410",
            etaText: "35-45 min",
            discountBadge: nil,
            description: "Hand-cast brass diyas with etched floral motifs, polished by hand and finished with a protective lacquer coat.",
            distance: "1.4 km"
        )
    ]

    private static let productsByCategory: [LocalCategory: [Product]] = Dictionary(grouping: products, by: \.category)

    static func allItems(for category: LocalCategory) -> [Product] {
        productsByCategory[category] ?? []
    }

    static func recommendations(for product: Product, limit: Int = 6) -> [Product] {
        Array(products.filter { $0.category == product.category && $0.id != product.id }.prefix(limit))
    }

    static let seasonalHighlights: [SeasonalHighlight] = {
        func highlight(
            productName: String,
            badge: String,
            title: String,
            subtitle: String,
            windowValue: String,
            priceLabel: String = "farmgate price"
        ) -> SeasonalHighlight? {
            guard let product = products.first(where: { $0.name == productName }) else { return nil }
            return SeasonalHighlight(
                badge: badge,
                title: title,
                subtitle: subtitle,
                imageSeed: product.imageSeed,
                category: product.category,
                rating: product.rating,
                ratingCount: product.ratingCount,
                windowLabel: product.category == .handicrafts ? "craft time" : "harvest window",
                windowValue: windowValue,
                priceLabel: priceLabel,
                priceValue: product.category == .handicrafts ? product.price : "\(product.price)/kg",
                product: product
            )
        }

        return [
            highlight(
                productName: "Alphonso Mangoes",
                badge: "Trending",
                title: "Malihabad Alphonso Mangoes",
                subtitle: "Ripened on the tree in UP's mango belt",
                windowValue: "Apr – Jun"
            ),
            highlight(
                productName: "Farm Tomatoes",
                badge: "Popular",
                title: "Sonipat Farm Tomatoes",
                subtitle: "Picked at dawn from a no-spray kitchen garden",
                windowValue: "Year-round"
            ),
            highlight(
                productName: "Blue Pottery Bowl Set",
                badge: "Featured",
                title: "Jaipur Blue Pottery",
                subtitle: "Hand-thrown and fired in a wood kiln",
                windowValue: "3–5 days",
                priceLabel: "starting price"
            )
        ].compactMap { $0 }
    }()
}
