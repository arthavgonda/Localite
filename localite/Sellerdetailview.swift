//
//  Sellerdetailview.swift
//  localite
//
//  Created by ANOOP on 18/07/26.
//

import SwiftUI

struct SellerDetailView: View {
    let seller: Seller
    let onClose: () -> Void
    @State private var cartCount = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroImage

                    VStack(alignment: .leading, spacing: 22) {
                        infoRow

                        if let discount = seller.discountBadge {
                            discountBanner(discount)
                        }

                        mostPopularSection

                        aboutSection
                    }
                    .padding(24)
                    .padding(.bottom, cartCount > 0 ? 80 : 24)
                    .background(
                        Color(.systemBackground)
                            .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
                    )
                    .offset(y: -24)
                }
            }
            .scrollIndicators(.hidden)

            if cartCount > 0 {
                cartBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
    }

    private var heroImage: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(seed: seller.imageSeed, width: 800, height: 900)
                .frame(height: 320)
                .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 320)

            HStack {
                Button(action: onClose) {
                    Image(systemName: "chevron.left")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 32, height: 32)
                        .background(.white, in: Circle())
                        .frame(width: 44, height: 44)
                }
                Spacer()
                HStack(spacing: 8) {
                    circleIconButton("heart")
                    circleIconButton("square.and.arrow.up")
                    circleIconButton("magnifyingglass")
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 46)
            .frame(maxHeight: .infinity, alignment: .top)

            VStack(alignment: .leading, spacing: 4) {
                Text(seller.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                HStack(spacing: 3) {
                    Text("More info")
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .frame(height: 320)
    }

    private func circleIconButton(_ icon: String) -> some View {
        Button {
        } label: {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 32, height: 32)
                .background(.white, in: Circle())
                .frame(width: 44, height: 44)
        }
    }

    private var infoRow: some View {
        HStack {
            infoColumn(icon: "star.fill", iconColor: .yellow, title: String(format: "%.1f", seller.rating), subtitle: "(\(seller.ratingCount))")
            Divider().frame(height: 30)
            infoColumn(icon: nil, iconColor: .clear, title: seller.feeText, subtitle: "delivery")
            Divider().frame(height: 30)
            infoColumn(icon: "clock.fill", iconColor: .secondary, title: seller.etaText, subtitle: "eta")
        }
        .frame(maxWidth: .infinity)
    }

    private func infoColumn(icon: String?, iconColor: Color, title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(iconColor)
                }
                Text(title)
                    .font(.subheadline.weight(.bold))
            }
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func discountBanner(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .font(.title3)
                .foregroundStyle(.red)
                .padding(10)
                .background(Color.red.opacity(0.12), in: Circle())

            Text(text)
                .font(.subheadline.weight(.medium))

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var mostPopularSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Most Popular")
                    .font(.title3.weight(.bold))
                Spacer()
                HStack(spacing: 4) {
                    Text("All")
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(seller.products) { product in
                        DetailProductCard(product: product) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                cartCount += 1
                            }
                        }
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
            Text(seller.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var cartBar: some View {
        Button {
        } label: {
            HStack {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 28, height: 28)
                    Text("\(cartCount)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
                Text("View Cart")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color.primary, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
    }
}

private struct DetailProductCard: View {
    let product: Product
    let onAdd: () -> Void

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
                        .background(Color.red, in: Capsule())
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .frame(width: 28, height: 28)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        .frame(width: 44, height: 44)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(product.price)
                        .font(.subheadline.weight(.bold))
                    if let original = product.originalPrice {
                        Text(original)
                            .font(.caption)
                            .strikethrough()
                            .foregroundStyle(.secondary)
                    }
                }
                Text(product.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(width: 128, alignment: .leading)
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
    SellerDetailView(seller: LocalStore.sellers[0], onClose: {})
}
