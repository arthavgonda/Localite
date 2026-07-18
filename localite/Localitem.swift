//
//  Localitem.swift
//  localite
//
//  Created by ANOOP on 18/07/26.
//

import SwiftUI

enum LocalCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case fruits = "Fruits"
    case handicrafts = "Handicrafts"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .fruits: return "leaf.fill"
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

    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}

struct Seller: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: LocalCategory
    let imageSeed: String
    let rating: Double
    let ratingCount: String
    let feeText: String
    let etaText: String
    let discountBadge: String?
    let description: String
    let distance: String
    let products: [Product]

    static func == (lhs: Seller, rhs: Seller) -> Bool {
        lhs.id == rhs.id
    }
}

struct PopularHighlight: Identifiable {
    let id = UUID()
    let product: Product
    let seller: Seller
}

enum LocalStore {
    static let sellers: [Seller] = [
        Seller(
            name: "Ravi's Orchard",
            category: .fruits,
            imageSeed: "orchard-mango-01",
            rating: 4.9,
            ratingCount: "1.2k",
            feeText: "From ₹40",
            etaText: "20-30 min",
            discountBadge: "Up to 25% off mangoes this week",
            description: "A third-generation family orchard on the outskirts of the city, growing Alphonso and Kesar mangoes without cold storage. Everything is picked the same morning it's listed.",
            distance: "0.4 km",
            products: [
                Product(name: "Alphonso Mangoes (1kg)", price: "₹180", originalPrice: "₹230", imageSeed: "mango-01", discountPercent: 22),
                Product(name: "Kesar Mangoes (1kg)", price: "₹150", originalPrice: nil, imageSeed: "mango-02", discountPercent: nil),
                Product(name: "Raw Mango Pickle", price: "₹120", originalPrice: nil, imageSeed: "pickle-01", discountPercent: nil)
            ]
        ),
        Seller(
            name: "Meera's Studio",
            category: .handicrafts,
            imageSeed: "pottery-studio-01",
            rating: 4.8,
            ratingCount: "860",
            feeText: "From ₹60",
            etaText: "30-40 min",
            discountBadge: "Festive season, 15% off pottery",
            description: "Hand-thrown blue pottery glazed with cobalt and quartz, fired in a wood kiln using techniques passed down since the Mughal era.",
            distance: "1.1 km",
            products: [
                Product(name: "Blue Pottery Bowl Set", price: "₹950", originalPrice: "₹1,120", imageSeed: "pottery-01", discountPercent: 15),
                Product(name: "Hand-painted Vase", price: "₹1,200", originalPrice: nil, imageSeed: "pottery-02", discountPercent: nil),
                Product(name: "Ceramic Coasters (Set of 4)", price: "₹450", originalPrice: nil, imageSeed: "pottery-03", discountPercent: nil)
            ]
        ),
        Seller(
            name: "Grove Fresh",
            category: .fruits,
            imageSeed: "lychee-grove-01",
            rating: 4.7,
            ratingCount: "540",
            feeText: "From ₹35",
            etaText: "15-25 min",
            discountBadge: nil,
            description: "Small-batch shahi lychees with a delicate rose fragrance, hand-picked to preserve the thin, blushing skin.",
            distance: "0.8 km",
            products: [
                Product(name: "Shahi Lychee (1kg)", price: "₹220", originalPrice: nil, imageSeed: "lychee-01", discountPercent: nil),
                Product(name: "Lychee Juice (1L)", price: "₹140", originalPrice: nil, imageSeed: "juice-01", discountPercent: nil)
            ]
        ),
        Seller(
            name: "Ganga Looms",
            category: .handicrafts,
            imageSeed: "silk-loom-01",
            rating: 5.0,
            ratingCount: "312",
            feeText: "From ₹80",
            etaText: "40-50 min",
            discountBadge: nil,
            description: "Pure silk stoles woven on a traditional pit loom, with hand-tied zari borders that take nearly two days to complete.",
            distance: "2.3 km",
            products: [
                Product(name: "Hand-loom Silk Stole", price: "₹1,450", originalPrice: nil, imageSeed: "silk-01", discountPercent: nil),
                Product(name: "Zari Border Dupatta", price: "₹1,900", originalPrice: "₹2,200", imageSeed: "silk-02", discountPercent: 14)
            ]
        ),
        Seller(
            name: "Valley Fresh Market",
            category: .fruits,
            imageSeed: "apple-valley-01",
            rating: 4.8,
            ratingCount: "970",
            feeText: "From ₹45",
            etaText: "25-35 min",
            discountBadge: "Weekend apple sale",
            description: "Crisp, cold-stored Kashmiri apples with a deep red blush, grown in the high altitude orchards of the Shopian valley.",
            distance: "2.0 km",
            products: [
                Product(name: "Kashmiri Apples (1kg)", price: "₹160", originalPrice: "₹190", imageSeed: "apple-01", discountPercent: 16),
                Product(name: "Apple Cider (500ml)", price: "₹130", originalPrice: nil, imageSeed: "cider-01", discountPercent: nil)
            ]
        ),
        Seller(
            name: "Moradabad Metalworks",
            category: .handicrafts,
            imageSeed: "brass-work-01",
            rating: 4.9,
            ratingCount: "410",
            feeText: "From ₹70",
            etaText: "35-45 min",
            discountBadge: nil,
            description: "Hand-cast brass diyas with etched floral motifs, polished by hand and finished with a protective lacquer coat.",
            distance: "1.4 km",
            products: [
                Product(name: "Brass Diya Set (6 pcs)", price: "₹680", originalPrice: nil, imageSeed: "brass-01", discountPercent: nil),
                Product(name: "Engraved Brass Tray", price: "₹1,050", originalPrice: nil, imageSeed: "brass-02", discountPercent: nil)
            ]
        )
    ]

    static func highlights(for category: LocalCategory) -> [PopularHighlight] {
        sellers
            .filter { $0.category == category }
            .compactMap { seller in
                guard let firstProduct = seller.products.first else { return nil }
                return PopularHighlight(product: firstProduct, seller: seller)
            }
    }
}
