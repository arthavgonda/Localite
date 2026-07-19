//
//  Itemdetailview.swift
//  localite
//
//  Created by ANOOP on 19/07/26.
//

import SwiftUI

struct LocalItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    var description: String = ""

    var origin: String = "Jolarpettai, Tamil Nadu"
    var taste: String = "Sweet and aromatic"
    var impactTitle: String = "Farmer impact"
    var impact: String = "Directly supports local farmers."
    var isEcoFriendly: Bool = false
    var unit: String = "1 kg"
    var shelfLife: String = "3-4 days"
    var allergyInfo: String = "None"
    var price: Double = 150.0
    var availableColors: [Color]? = nil
}

struct ItemDetailView: View {
    let item: LocalItem
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var cart: CartStore
    @State private var showMoreDetails = false
    @State private var selectedColor: Color? = nil
    @State private var addTrigger = 0
    @State private var showCart = false
    @State private var justAdded = false
    @State private var settleWorkItem: DispatchWorkItem?

    private let heroHeight: CGFloat = 350

    private var quantityInCart: Int { cart.localQuantity(for: item) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroImage

                VStack(alignment: .leading, spacing: 22) {
                    if !item.description.isEmpty {
                        aboutSection
                    }

                    if let colors = item.availableColors, !colors.isEmpty {
                        colorSection(colors)
                    }

                    HStack(spacing: 14) {
                        ItemInfoCard(icon: "mappin.circle.fill", title: "Origin", text: item.origin)
                        ItemInfoCard(icon: "sparkles", title: item.isEcoFriendly ? "Craftsmanship" : "Taste", text: item.taste)
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    impactCard

                    trustBadge

                    detailsDisclosure

                    Spacer().frame(height: 100)
                }
                .padding(24)
                .padding(.bottom, 110)
                .background(
                    LocaliteTheme.background
                        .clipShape(ItemCornerShape(radius: 28, corners: [.topLeft, .topRight]))
                )
                .offset(y: -24)
            }
        }
        .coordinateSpace(name: "scroll")
        .scrollIndicators(.hidden)
        .background(LocaliteTheme.background)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .top) { closeButton }
        .overlay(alignment: .bottom) { buySection }
        .overlay(alignment: .bottom) {
            if quantityInCart > 0 {
                CartAddedBanner(
                    title: justAdded ? "Added to cart" : "In your basket",
                    detail: "\(quantityInCart) × ₹\(Int(item.price)) · Tap to view cart"
                ) {
                    showCart = true
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 96)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: quantityInCart)
        .onChange(of: quantityInCart) { old, new in
            guard new > old else { return }
            settleWorkItem?.cancel()
            justAdded = true
            let work = DispatchWorkItem { justAdded = false }
            settleWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: work)
        }
        .sheet(isPresented: $showCart) {
            CartView(onClose: { showCart = false })
                .environmentObject(cart)
        }
    }

    private var heroImage: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("scroll")).minY
            let stretch = max(0, minY)
            let height = heroHeight + stretch

            ZStack(alignment: .bottomLeading) {
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.subtitle.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(0.6)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(item.title.replacingOccurrences(of: "\n", with: " "))
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .frame(width: proxy.size.width, height: height)
            .offset(y: -stretch)
        }
        .frame(height: heroHeight)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
        }
        .padding(.horizontal, 12)
        .padding(.top, 46)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About this item")
                .font(.title3.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
            Text(item.description)
                .font(.subheadline)
                .foregroundStyle(LocaliteTheme.inkSecondary)
                .lineSpacing(4)
        }
    }

    private func colorSection(_ colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available colors")
                .font(.title3.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)

            HStack(spacing: 16) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? LocaliteTheme.ink : Color.clear, lineWidth: 3)
                                .padding(-4)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedColor = color
                            }
                        }
                }
            }
        }
        .onAppear {
            if selectedColor == nil {
                selectedColor = colors.first
            }
        }
    }

    private var impactCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: item.isEcoFriendly ? "leaf.fill" : "person.3.fill")
                    .foregroundStyle(LocaliteTheme.accent)
                Text(item.impactTitle)
                    .font(.headline)
                    .foregroundStyle(LocaliteTheme.accent)
            }
            Text(item.impact)
                .font(.subheadline)
                .foregroundStyle(LocaliteTheme.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LocaliteTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var trustBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundStyle(LocaliteTheme.ink)

            VStack(alignment: .leading, spacing: 2) {
                Text("100% authentic local")
                    .font(.headline)
                    .foregroundStyle(LocaliteTheme.ink)
                Text("Sourced directly from verified local artisans and farmers.")
                    .font(.caption)
                    .foregroundStyle(LocaliteTheme.inkSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LocaliteTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var detailsDisclosure: some View {
        DisclosureGroup(isExpanded: $showMoreDetails) {
            VStack(alignment: .leading, spacing: 12) {
                ItemDetailRow(title: "Unit", value: item.unit)
                ItemDetailRow(title: "Shelf life", value: item.shelfLife)
                ItemDetailRow(title: "Allergy info", value: item.allergyInfo)

                Text("Disclaimer: images are for visual representation only. Actual product may vary slightly.")
                    .font(.caption2)
                    .foregroundStyle(LocaliteTheme.inkMuted)
                    .padding(.top, 8)
            }
            .padding(.top, 12)
        } label: {
            Text("More details")
                .font(.headline)
                .foregroundStyle(LocaliteTheme.ink)
        }
        .tint(LocaliteTheme.ink)
        .padding(16)
        .background(LocaliteTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var buySection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Price")
                    .font(.caption)
                    .foregroundStyle(LocaliteTheme.inkSecondary)
                Text("₹\(Int(item.price))")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
            }
            Spacer()
            Button {
                addTrigger += 1
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    cart.addLocal(item)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bag.badge.plus")
                    Text("Add to cart")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(LocaliteTheme.ink, in: Capsule())
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: addTrigger)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Reusable Components
struct ItemInfoCard: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(LocaliteTheme.accent)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(LocaliteTheme.inkSecondary)
            }
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(LocaliteTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LocaliteTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ItemDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(LocaliteTheme.inkSecondary)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(LocaliteTheme.ink)
        }
    }
}

private struct ItemCornerShape: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ItemDetailView(
        item: LocalItem(
            title: "Alphonso\nMangoes",
            subtitle: "Trending",
            imageName: "mango_hero",
            description: "Grown on a third-generation family orchard on the outskirts of the city, without cold storage.",
            price: 180
        )
    )
}
