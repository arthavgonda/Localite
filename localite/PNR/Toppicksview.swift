//
//  Toppicksview.swift
//  localite
//
//  Created by ANOOP on 19/07/26.
//

import SwiftUI

struct TopPicksView: View {
    let station: Station
    @EnvironmentObject private var cart: CartStore

    @State private var selectedItem: LocalItem?
    @State private var showAIInsights = false
    @State private var isGeneratingInsights = true
    @State private var aiInsightText = ""
    @State private var sheetDetent: PresentationDetent = .medium

    let items = [
        LocalItem(
            title: "Fresh\nMangoes", subtitle: "Local Produce", imageName: "indian_fruits",
            description: "Known as the 'King of Fruits', these Devgad Alphonso mangoes are world-renowned for their vibrant saffron color, rich sweetness, and completely fibreless texture. Grown in the unique coastal climate of the Konkan region, they offer a burst of tropical sunshine in every bite.",
            origin: "Devgad, Konkan Coast", taste: "Sweet, rich, and intensely aromatic.",
            impactTitle: "Farmer Impact", impact: "Directly supports over 50 local Alphonso mango farmers.", isEcoFriendly: false,
            unit: "1 Dozen", shelfLife: "4-5 Days", allergyInfo: "None", price: 650.0
        ),
        LocalItem(
            title: "Hot\nJalebis", subtitle: "Authentic Sweets", imageName: "indian_sweets",
            description: "A legendary street food dessert, these jalebis are deep-fried in pure desi ghee and soaked in a fragrant saffron syrup. Best enjoyed piping hot, their delicate, crystalline crunch gives way to a warm, sugary explosion that has delighted generations in Old Delhi.",
            origin: "Chandni Chowk, Old Delhi", taste: "Crispy outside, syrupy inside.",
            impactTitle: "Community Impact", impact: "Supports a 140-year-old family-run sweet shop.", isEcoFriendly: false,
            unit: "500 Grams", shelfLife: "2 Days", allergyInfo: "Contains Gluten, Dairy", price: 200.0
        ),
        LocalItem(
            title: "Khurja\nCeramics", subtitle: "Traditional Crafts", imageName: "indian_handicrafts",
            description: "This stunning ceramic pottery is handcrafted by master artisans in Khurja. Known as 'magic clay', the local soil is shaped on traditional wheels and hand-painted with vibrant, intricate floral motifs before being kiln-fired, making every single piece a unique work of art.",
            origin: "Khurja, Uttar Pradesh", taste: "Intricate, earthy, hand-painted.",
            impactTitle: "Environmental Impact", impact: "Saves 2.5kg of carbon emissions. Uses natural firing techniques.", isEcoFriendly: true,
            unit: "Set of 2 Cups", shelfLife: "Lifetime", allergyInfo: "None", price: 450.0
        ),
        LocalItem(
            title: "Blue Pottery\nVases", subtitle: "Traditional Crafts", imageName: "indian_handicrafts",
            description: "Famous Jaipur Blue Pottery crafted without clay. Made using quartz stone powder, powdered glass, and multani mitti, these vases are hand-painted with signature blue and white floral designs inspired by Turko-Persian motifs.",
            origin: "Jaipur, Rajasthan", taste: "Vibrant, historic, quartz-based.",
            impactTitle: "Artisan Impact", impact: "Supports traditional Jaipur artisan families.", isEcoFriendly: true,
            unit: "1 Vase", shelfLife: "Lifetime", allergyInfo: "None", price: 850.0
        ),
        LocalItem(
            title: "Terracotta\nPlanters", subtitle: "Traditional Crafts", imageName: "indian_handicrafts",
            description: "Earthy and rustic, these handcrafted terracotta planters are baked in traditional kilns. Perfect for indoor plants, their porous nature allows roots to breathe and prevents overwatering, bringing a touch of rural India to your urban home.",
            origin: "Bishnupur, West Bengal", taste: "Rustic, unglazed, earthy.",
            impactTitle: "Environmental Impact", impact: "100% biodegradable and zero waste production.", isEcoFriendly: true,
            unit: "Set of 3", shelfLife: "Lifetime", allergyInfo: "None", price: 300.0
        ),
        LocalItem(
            title: "Kanjeevaram\nSilk Sari", subtitle: "Handloom Weaves", imageName: "indian_handicrafts",
            description: "Woven in the temple town of Kanchipuram, this sari is a masterpiece of Indian handloom. Made from pure mulberry silk thread and interwoven with gold and silver zari, its rich texture and majestic motifs take weeks of painstaking manual loom work to complete.",
            origin: "Kanchipuram, TN", taste: "Exquisite Craftsmanship",
            impactTitle: "Artisan Impact", impact: "Preserves ancient handloom traditions and supports weaver communities.", isEcoFriendly: true,
            unit: "1 Sari", shelfLife: "Heirloom", allergyInfo: "None", price: 15000.0, availableColors: [.red, .blue, .purple, .green]
        ),
        LocalItem(
            title: "Organic\nJaggery", subtitle: "Local Produce", imageName: "indian_sweets",
            description: "A wholesome, unrefined sugar alternative, this organic jaggery is made by boiling concentrated sugarcane juice in large iron vessels. It boasts a deep, earthy caramel flavor and is packed with natural iron and minerals, making it a healthy staple for your pantry.",
            origin: "Kolhapur, Maharashtra", taste: "Rich caramel sweetness.",
            impactTitle: "Farmer Impact", impact: "Supports sustainable sugarcane farming without chemical processing.", isEcoFriendly: true,
            unit: "1 Kg", shelfLife: "6 Months", allergyInfo: "None", price: 120.0
        ),
        LocalItem(
            title: "Bamboo\nLamp Shade", subtitle: "Eco-Friendly Crafts", imageName: "indian_handicrafts",
            description: "Handwoven by indigenous artisans using locally sourced, fast-growing bamboo, this lamp shade casts beautiful, warm geometric shadows. It brings a touch of rustic, earthy elegance to any room while remaining 100% biodegradable and eco-friendly.",
            origin: "Majuli, Assam", taste: "Rustic, warm, and sustainable.",
            impactTitle: "Environmental Impact", impact: "Zero waste and fully biodegradable. Supports indigenous tribes.", isEcoFriendly: true,
            unit: "1 Piece", shelfLife: "10 Years", allergyInfo: "None", price: 850.0
        ),
        LocalItem(
            title: "Spicy\nBhujia", subtitle: "Local Snacks", imageName: "indian_sweets",
            description: "A beloved Indian namkeen, this Bikaneri Bhujia is made from moth bean flour and a secret blend of desert spices. Double-fried to crispy perfection, its fiery, savory crunch is highly addictive and pairs perfectly with a hot cup of evening chai.",
            origin: "Bikaner, Rajasthan", taste: "Crispy, fiery, and deeply savory.",
            impactTitle: "Community Impact", impact: "Provides steady employment to women cooperatives in Rajasthan.", isEcoFriendly: false,
            unit: "400 Grams", shelfLife: "3 Months", allergyInfo: "Contains Gram Flour, Spices", price: 150.0
        ),
        LocalItem(
            title: "Kashmiri\nSaffron", subtitle: "Premium Spices", imageName: "autumn_coffee",
            description: "The most expensive spice in the world, these vibrant red saffron stigmas are hand-plucked at dawn in the valleys of Pampore. Just a few strands are enough to impart a heavenly floral aroma and a rich golden hue to your biryanis and desserts.",
            origin: "Pampore, Kashmir", taste: "Floral and honey-like",
            impactTitle: "Farmer Impact", impact: "Supports saffron growers in conflict-affected regions, offering fair wages.", isEcoFriendly: false,
            unit: "1 Gram", shelfLife: "2 Years", allergyInfo: "None", price: 350.0
        ),
        LocalItem(
            title: "Terracotta\nWind Chime", subtitle: "Home Decor", imageName: "indian_handicrafts",
            description: "Sculpted from the rich red clay of Bengal, these terracotta wind chimes are sun-dried and fired in traditional mud kilns. When the breeze hits, they produce a deeply melodic, earthy clinking sound that instantly brings a sense of peace to your balcony.",
            origin: "Bishnupur, West Bengal", taste: "Melodic, earthy tones.",
            impactTitle: "Environmental Impact", impact: "Sun-dried and baked in mud kilns, leaving virtually zero carbon footprint.", isEcoFriendly: true,
            unit: "1 Piece", shelfLife: "Lifetime", allergyInfo: "None", price: 300.0
        ),
        LocalItem(
            title: "Filter\nCoffee Powder", subtitle: "Local Beverages", imageName: "indian_sweets",
            description: "A robust blend of Arabica and Robusta beans, sourced from the misty hills of Coorg. Roasted to perfection and mixed with a hint of chicory, this powder brews a thick, intense decoction that is the soul of authentic South Indian filter coffee.",
            origin: "Coorg, Karnataka", taste: "Strong, roasted, slightly bitter.",
            impactTitle: "Farmer Impact", impact: "Directly from shade-grown estates, promoting local biodiversity.", isEcoFriendly: true,
            unit: "250 Grams", shelfLife: "9 Months", allergyInfo: "None", price: 280.0
        ),
        LocalItem(
            title: "Chanderi\nDupatta", subtitle: "Handloom Weaves", imageName: "indian_handicrafts",
            description: "Known for its sheer texture, lightweight feel, and luxurious drape, this Chanderi dupatta is handwoven using traditional techniques. Its delicate pastel hues and fine zari motifs make it a versatile and elegant addition to any ethnic wardrobe.",
            origin: "Chanderi, Madhya Pradesh", taste: "Lightweight, sheer texture, fine zari work.",
            impactTitle: "Artisan Impact", impact: "Provides sustainable livelihoods for over 30 master weavers.", isEcoFriendly: true,
            unit: "1 Piece", shelfLife: "Lifetime", allergyInfo: "None", price: 1200.0, availableColors: [.pink, .blue, .yellow, .green]
        ),
        LocalItem(
            title: "Darjeeling\nTea Leaves", subtitle: "Premium Beverages", imageName: "indian_sweets",
            description: "Often called the 'Champagne of Teas', these first-flush Darjeeling leaves are grown at high altitudes in the Himalayas. When brewed, they produce a light, bright liquor with a distinct muscatel flavor and a delicate floral finish.",
            origin: "Darjeeling, West Bengal", taste: "Floral, muscatel, and delicate.",
            impactTitle: "Farmer Impact", impact: "Supports fair trade tea estates and protects local mountain flora.", isEcoFriendly: true,
            unit: "100 Grams", shelfLife: "1 Year", allergyInfo: "None", price: 500.0
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if showAIInsights {
                        AIInsightsCard(
                            stationName: station.name,
                            isGenerating: isGeneratingInsights,
                            insightText: aiInsightText,
                            onClose: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showAIInsights = false
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            Button {
                                selectedItem = item
                            } label: {
                                TopPickRow(item: item)
                            }
                            .buttonStyle(.plain)

                            if item.id != items.last?.id {
                                Divider().overlay(LocaliteTheme.hairline).padding(.leading, 82)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color.clear)
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
                .environmentObject(cart)
        }
        .presentationDetents([.medium, .large], selection: $sheetDetent)
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text(station.name)
                .font(.title.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)

            Spacer()

            if !showAIInsights {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showAIInsights = true
                        isGeneratingInsights = true
                        sheetDetent = .large
                    }
                    simulateAIGeneration()
                } label: {
                    Image(systemName: "sparkles")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(LocaliteTheme.accent, in: Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    private func simulateAIGeneration() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isGeneratingInsights = false
                aiInsightText = "\(station.name) is a vibrant hub deeply rooted in traditional arts and local commerce. The surrounding region is famous for its generational artisans and unique culinary heritage.\n\nFrom bustling wholesale markets offering fresh, organic produce to hidden, centuries-old lanes where master craftsmen shape intricate pottery and handloom textiles, the area serves as a beautiful crossroad of culture, sustainability, and authentic Indian flavors.\n\nThe local community thrives on this rich ecosystem of micro-entrepreneurs. Every item sourced from here carries the legacy of its people, reflecting a deep respect for natural resources and a commitment to preserving historical craftsmanship against the tide of mass production."
            }
        }
    }
}

private struct AIInsightsCard: View {
    let stationName: String
    let isGenerating: Bool
    let insightText: String
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(LocaliteTheme.accent)
                Text("AI insights: \(stationName)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(LocaliteTheme.inkSecondary)
                        .frame(width: 24, height: 24)
                        .background(LocaliteTheme.ink.opacity(0.06), in: Circle())
                }
            }

            if isGenerating {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(LocaliteTheme.accent)
                    Text("Analyzing local culture, traditions, and specialties…")
                        .font(.subheadline)
                        .foregroundStyle(LocaliteTheme.inkSecondary)
                }
                .padding(.vertical, 6)
            } else {
                Text(insightText)
                    .font(.footnote)
                    .foregroundStyle(LocaliteTheme.inkSecondary)
                    .lineSpacing(4)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .background(LocaliteTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct TopPickRow: View {
    let item: LocalItem

    var body: some View {
        HStack(spacing: 16) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title.replacingOccurrences(of: "\n", with: " "))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(LocaliteTheme.inkSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(LocaliteTheme.inkMuted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    TopPicksView(
        station: Station(
            name: "Mathura Junction",
            code: "MTJ",
            arrivalTime: "18 Jul, 5:15 PM",
            latitude: 27.4924,
            longitude: 77.6737
        )
    )
}
