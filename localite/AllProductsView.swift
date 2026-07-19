import SwiftUI

struct AllProductsView: View {
    let title: String
    let items: [Product]
    let onSelect: (Product, String) -> Void
    let onAdd: (Product) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var cart: CartStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title.weight(.bold))
                            .foregroundStyle(LocaliteTheme.ink)
                        Text("\(items.count) items")
                            .font(.subheadline)
                            .foregroundStyle(LocaliteTheme.inkMuted)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 70)
                    .padding(.bottom, 20)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(items) { product in
                            AllProductCard(product: product, onAdd: { onAdd(product) })
                                .onTapGesture { onSelect(product, product.id.uuidString) }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .scrollIndicators(.hidden)
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(LocaliteTheme.ink)
                    .frame(width: 40, height: 40)
                    .background(Color.white, in: Circle())
                    .shadow(color: .black.opacity(0.10), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct AllProductCard: View {
    let product: Product
    let onAdd: () -> Void

    @Environment(\.heroNamespace) private var heroNamespace
    @State private var addTrigger = 0
    @State private var isBouncing = false

    private func triggerAdd() {
        addTrigger += 1
        withAnimation(.easeOut(duration: 0.1)) { isBouncing = true }
        onAdd()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { isBouncing = false }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RemoteImage(seed: product.imageSeed, width: 600, height: 500)
                    .matchedGeometryEffectIfAvailable(id: product.id.uuidString, in: heroNamespace)
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 18,
                            style: .continuous
                        )
                    )
                    .clipped()

                if let pct = product.discountPercent {
                    Text("-\(pct)%")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(LocaliteTheme.accent, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(10)
                }

                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(LocaliteTheme.ink, in: Circle())
                    .scaleEffect(isBouncing ? 0.82 : 1.0)
                    .contentShape(Circle())
                    .highPriorityGesture(TapGesture().onEnded(triggerAdd))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(10)
                    .sensoryFeedback(.impact(weight: .light), trigger: addTrigger)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(LocaliteTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: 36, alignment: .topLeading)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(LocaliteTheme.accent)
                    Text(product.originVillage)
                        .font(.caption2)
                        .foregroundStyle(LocaliteTheme.inkMuted)
                        .lineLimit(1)
                }

                HStack(spacing: 10) {
                    Label {
                        Text(String(format: "%.1f", product.rating))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(LocaliteTheme.ink)
                    } icon: {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(red: 0.98, green: 0.75, blue: 0.15))
                    }

                    Text("·")
                        .foregroundStyle(LocaliteTheme.inkMuted)

                    Label {
                        Text(product.etaText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(LocaliteTheme.inkMuted)
                    } icon: {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                            .foregroundStyle(LocaliteTheme.inkMuted)
                    }
                }

                Divider()
                    .padding(.vertical, 2)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(product.price)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                    if let orig = product.originalPrice {
                        Text(orig)
                            .font(.caption2)
                            .strikethrough()
                            .foregroundStyle(Color.gray.opacity(0.7))
                    }
                    Spacer()
                    Text(product.distance)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(LocaliteTheme.accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}
