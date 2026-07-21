import SwiftUI

struct ProductStackCardView: View {
    let product: Product
    var isFront: Bool = true
    var brightness: Double = 0

    private let cardWidth: CGFloat = 340
    private let cardHeight: CGFloat = 190

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: product.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .empty:
                    Color.gray.opacity(0.2)
                default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipped()

            if !isFront {
                Rectangle()
                    .fill(Color.black.opacity(brightness < -0.3 ? 0.5 : 0.35))
                    .frame(width: cardWidth, height: cardHeight)
            }

            LinearGradient(
                colors: [.black.opacity(0.75), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            .frame(width: cardWidth, height: cardHeight)

            if isFront {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(product.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .padding(16)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(isFront ? 0.2 : 0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(isFront ? 0.25 : 0.15), radius: isFront ? 10 : 4, x: 0, y: isFront ? 6 : 2)
    }
}

#Preview {
    ZStack {
        ProductStackCardView(product: Product.localPicksSample[2], isFront: false, brightness: -0.35)
            .scaleEffect(0.90)
            .rotationEffect(.degrees(4))
            .offset(y: 22)
        ProductStackCardView(product: Product.localPicksSample[1], isFront: false, brightness: -0.2)
            .scaleEffect(0.95)
            .rotationEffect(.degrees(-3))
            .offset(y: 12)
        ProductStackCardView(product: Product.localPicksSample[0])
    }
    .padding()
}
