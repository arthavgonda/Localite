import Foundation

struct Product: Identifiable, Equatable {
    let id: UUID = UUID()
    let name: String
    let subtitle: String
    let priceLabel: String
    let rating: Double
    let imageURL: URL?
    let isCertifiedLocal: Bool

    static let heroSample = Product(
        name: "Malihabad Alphonso Mangoes",
        subtitle: "Trending Now",
        priceLabel: "₹180/kg",
        rating: 4.9,
        imageURL: URL(string: "https://images.unsplash.com/photo-1591073113125-e46713c829ed?q=80&w=700&auto=format&fit=crop"),
        isCertifiedLocal: true
    )

    static let localPicksSample: [Product] = [
        Product(
            name: "Dilli Ki Chaat Kit",
            subtitle: "Chandni Chowk · 400 yrs of recipe lineage",
            priceLabel: "₹320",
            rating: 4.8,
            imageURL: URL(string: "https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=700&auto=format&fit=crop"),
            isCertifiedLocal: true
        ),
        Product(
            name: "Old Delhi Spice Box",
            subtitle: "Khari Baoli · family run since 1920",
            priceLabel: "₹410",
            rating: 4.7,
            imageURL: URL(string: "https://images.unsplash.com/photo-1606491956689-2ea866880c84?q=80&w=500&auto=format&fit=crop"),
            isCertifiedLocal: true
        ),
        Product(
            name: "Handloom Table Runner",
            subtitle: "Chandni Chowk weavers collective",
            priceLabel: "₹560",
            rating: 4.6,
            imageURL: URL(string: "https://images.unsplash.com/photo-1610701596007-11502861dcfa?q=80&w=500&auto=format&fit=crop"),
            isCertifiedLocal: false
        )
    ]
}
