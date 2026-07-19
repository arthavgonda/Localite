//
//  Productdetailview.swift
//  localite
//
//  Created by ANOOP on 19/07/26.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    let sourceID: String?
    let onClose: () -> Void

    @EnvironmentObject private var cart: CartStore
    @Environment(\.heroNamespace) private var heroNamespace
    @State private var quantity = 1
    @State private var isFavorite = false
    @State private var pushedProduct: Product?
    @State private var showCart = false
    @State private var addTrigger = 0

    private let ctaBarHeight: CGFloat = 94
    private let heroHeight: CGFloat = 320

    private var priceQualifier: String {
        product.category == .handicrafts ? "starting price" : "per kg"
    }

    private var recommendations: [Product] {
        LocalStore.recommendations(for: product)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage

                    VStack(alignment: .leading, spacing: 22) {
                        titleBlock
                        statRow

                        if let discount = product.discountPercent {
                            promoBanner(discount)
                        }

                        if !recommendations.isEmpty {
                            recommendationsSection
                        }

                        aboutSection
                        deliveryBadge
                    }
                    .padding(24)
                    .padding(.bottom, 110)
                    .background(
                        Color.white
                            .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
                    )
                    .offset(y: -24)
                }
            }
            .coordinateSpace(name: "scroll")
            .scrollIndicators(.hidden)

            ctaBar
        }
        .overlay(alignment: .top) { topControls }
        .cartAddedBanner(for: product, ctaBarHeight: ctaBarHeight) { showCart = true }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .fullScreenCover(item: $pushedProduct) { pushed in
            ProductDetailView(product: pushed, sourceID: nil, onClose: { pushedProduct = nil })
                .environmentObject(cart)
        }
        .sheet(isPresented: $showCart) {
            CartView(onClose: { showCart = false })
        }
    }

    private var heroImage: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("scroll")).minY
            let stretch = max(0, minY)
            let height = heroHeight + stretch

            ZStack {
                RemoteImage(seed: product.imageSeed, width: 800, height: 900)
                    .matchedGeometryEffectIfAvailable(id: sourceID ?? product.id.uuidString, in: heroNamespace)
                    .frame(width: proxy.size.width, height: height)
                    .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.25), .clear, .black.opacity(0.35)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: proxy.size.width, height: height)
            }
            .frame(width: proxy.size.width, height: height)
            .offset(y: -stretch)
        }
        .frame(height: heroHeight)
    }

    private var topControls: some View {
        HStack {
            iconButton(systemName: "chevron.left", action: onClose)
            Spacer()
            HStack(spacing: 10) {
                favoriteButton
                shareButton
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 46)
    }

    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
                .frame(width: 40, height: 40)
                .glassEffect(.regular, in:Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
        }
    }

    private var favoriteButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isFavorite.toggle()
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isFavorite ? Color.red : LocaliteTheme.ink)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
        }
    }

    private var shareButton: some View {
        ShareLink(item: "\(product.name) on Localite, from \(product.originVillage)") {
            Image(systemName: "square.and.arrow.up")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(product.name)
                .font(.title2.weight(.heavy))
                .foregroundStyle(LocaliteTheme.ink)

            HStack(spacing: 5) {
                Image(systemName: "mappin.circle.fill")
                    .font(.callout)
                    .foregroundStyle(LocaliteTheme.inkMuted)
                Text("From \(product.originVillage)")
                    .font(.subheadline)
                    .foregroundStyle(LocaliteTheme.inkSecondary)
            }
        }
    }

    private var statRow: some View {
        HStack(spacing: 0) {
            statCell(value: String(format: "%.1f ★", product.rating), label: "\(product.ratingCount) ratings")
            Divider().frame(height: 30)
            statCell(value: product.price, label: priceQualifier)
            Divider().frame(height: 30)
            statCell(value: product.etaText, label: "delivery eta")
        }
        .padding(.vertical, 14)
        .overlay(alignment: .top) { Divider() }
        .overlay(alignment: .bottom) { Divider() }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
            Text(label)
                .font(.caption)
                .foregroundStyle(LocaliteTheme.inkSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func promoBanner(_ discount: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "tag.fill")
                .font(.subheadline)
                .foregroundStyle(LocaliteTheme.accent)
            Text("Harvest season, \(discount)% off this week")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(LocaliteTheme.accent)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LocaliteTheme.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You might also like")
                .font(.title3.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(recommendations) { recommended in
                        RecommendationCard(product: recommended) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                cart.add(recommended)
                            }
                        }
                        .onTapGesture { pushedProduct = recommended }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.title3.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)
            Text(product.description)
                .font(.subheadline)
                .foregroundStyle(LocaliteTheme.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var deliveryBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "shippingbox")
                .font(.subheadline)
                .foregroundStyle(LocaliteTheme.inkSecondary)
            Text("\(product.etaText) delivery, fulfilled locally")
                .font(.caption)
                .foregroundStyle(LocaliteTheme.inkSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LocaliteTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var ctaBar: some View {
        HStack(spacing: 14) {
            HStack(spacing: 14) {
                Button {
                    quantity = max(1, quantity - 1)
                } label: {
                    Image(systemName: "minus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(LocaliteTheme.inkSecondary)
                        .frame(width: 28, height: 28)
                }
                Text("\(quantity)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
                    .frame(minWidth: 16)
                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(LocaliteTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 4)

            Button {
                addTrigger += 1
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    cart.add(product, quantity: quantity)
                }
            } label: {
                Text("Add to basket · \(product.price)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(LocaliteTheme.ink, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.18), radius: 14, y: 6)
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: addTrigger)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 30)
    }
}

private struct RecommendationCard: View {
    let product: Product
    let onAdd: () -> Void
    @State private var isBouncing = false
    @State private var addTrigger = 0

    private func triggerAdd() {
        addTrigger += 1
        withAnimation(.easeOut(duration: 0.1)) {
            isBouncing = true
        }
        onAdd()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                isBouncing = false
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                RemoteImage(seed: product.imageSeed, width: 300, height: 300)
                    .frame(width: 128, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                if let discount = product.discountPercent {
                    Text("-\(discount)%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(LocaliteTheme.accent, in: Capsule())
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                Button(action: triggerAdd) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(LocaliteTheme.ink, in: Circle())
                        .scaleEffect(isBouncing ? 0.85 : 1.0)
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        .frame(width: 44, height: 44)
                }
                .sensoryFeedback(.impact(weight: .light), trigger: addTrigger)
                .padding(.bottom, 5)
                .padding(.trailing, 5)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(product.price)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                    if let original = product.originalPrice {
                        Text(original)
                            .font(.caption)
                            .strikethrough()
                            .foregroundStyle(Color.gray)
                    }
                }
                Text(product.name)
                    .font(.caption)
                    .foregroundStyle(LocaliteTheme.inkSecondary)
                    .lineLimit(2)
                    .frame(height: 28, alignment: .topLeading)
            }
        }
        .frame(width: 128, alignment: .leading)
    }
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

private struct RoundedCorner: Shape {
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
    ProductDetailView(
        product: LocalStore.products[0],
        sourceID: nil,
        onClose: {}
    )
    .environmentObject(CartStore())
}
