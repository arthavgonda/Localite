import SwiftUI

struct HeroCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let product: Product

    private let cardHeight: CGFloat = 230
    private let pinRange: CGFloat = 10

    var body: some View {
        let theme = theme(colorScheme)

        ZStack(alignment: .bottomLeading) {
            Group {
                AsyncImage(url: product.imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: 220, maxHeight: .infinity)
                                        .clipped()
                                default:
                                    Rectangle().fill(theme.cardBackground)
                                }
                            }
            }
            .frame(height: cardHeight)
            .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.02), Color.black.opacity(0.92)],
                startPoint: .top, endPoint: .bottom
            )

            if product.isCertifiedLocal {
                CertifiedStamp()
                    .frame(width: 46, height: 46)
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(product.subtitle.uppercased())
                    .font(Theme.mono(12, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(theme.marigold)
                    .lineLimit(1)

                Text(product.name)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(theme.textOnCard)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(product.priceLabel) · \(String(format: "%.1f", product.rating))★")
                    .font(Theme.mono(12, weight: .semibold))
                    .foregroundStyle(theme.textOnCard)
            }
            .padding(14)
        }
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [theme.glassBorder, Color.clear],
                        startPoint: .top, endPoint: .center
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 14)
    }
}

private struct CertifiedStamp: View {
    var body: some View {
        ZStack {
            Circle().stroke(Color(hex: "BD4433"), lineWidth: 2.5)
            Circle().strokeBorder(Color(hex: "BD4433"), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                .padding(6)
            VStack(spacing: 1) {
                Text("Cert.")
                    .font(.custom("Fraunces-SemiBold", size: 11).italic())
                Text("LOCAL")
                    .font(Theme.mono(7, weight: .bold))
            }
            .foregroundStyle(Color(hex: "BD4433"))
        }
    }
}

#Preview("Light") {
    HeroCardView(product: .heroSample)
        .padding()
        .background(Theme(colorScheme: .light).background)
}

#Preview("Dark") {
    HeroCardView(product: .heroSample)
        .padding()
        .background(Theme(colorScheme: .dark).background)
        .preferredColorScheme(.dark)
}
