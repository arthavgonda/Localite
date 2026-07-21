import SwiftUI

struct LocalPicksStackView: View {
    let products: [Product]
    @State private var order: [Int]
    @State private var dragOffset: CGSize = .zero

    init(products: [Product]) {
        self.products = products
        _order = State(initialValue: Array(products.indices))
    }

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(order.enumerated().reversed()), id: \.element) { depth, index in
                let position = order.firstIndex(of: index) ?? 0
                let isFront = position == 0

                ProductStackCardView(
                    product: products[index], 
                    isFront: isFront,
                    brightness: Double(position) * -0.15
                )
                .scaleEffect(1 - CGFloat(position) * 0.05)
                .rotationEffect(.degrees(isFront ? Double(dragOffset.width / 20) : (position == 1 ? -3 : 0)))
                .offset(x: isFront ? dragOffset.width : 0, y: CGFloat(position) * 8 + (isFront ? dragOffset.height * 0.15 : 0))
                .zIndex(Double(order.count - position))
                .gesture(
                    isFront ?
                    DragGesture()
                        .onChanged { dragOffset = $0.translation }
                        .onEnded { value in
                            if abs(value.translation.width) > 90 {
                                withAnimation(.interpolatingSpring(mass: 0.5, stiffness: 120, damping: 14)) {
                                    if let first = order.first {
                                        order.removeFirst()
                                        order.append(first)
                                    }
                                    dragOffset = .zero
                                }
                            } else {
                                withAnimation(.interpolatingSpring(mass: 0.4, stiffness: 200, damping: 18)) {
                                    dragOffset = .zero
                                }
                            }
                        }
                    : nil
                )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
    }
}

#Preview {
    LocalPicksStackView(products: Product.localPicksSample).padding()
}
