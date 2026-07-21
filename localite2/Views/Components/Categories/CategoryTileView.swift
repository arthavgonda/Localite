import SwiftUI

struct CategoryTileView: View {
    @Environment(\.colorScheme) private var colorScheme
    let item: CategoryItem
    var isPressed: Bool = false

    var body: some View {
        let theme = theme(colorScheme)
        ZStack(alignment: .topTrailing) {
            theme.categoryGradient(item.kind)

            Image(systemName: item.kind.symbolName)
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(.white.opacity(0.55))
                .padding(10)
                .padding(.top, 5)
                .scaleEffect(isPressed ? 1.12 : 1)
                .rotationEffect(.degrees(isPressed ? 6 : 0))
                .animation(.spring(response: 0.3, dampingFraction: 0.55), value: isPressed)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.kind.displayName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                Text(item.countLabel)
                    .font(Theme.mono(11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    CategoryTileView(item: CategoryItem.sample[0]).padding()
}
