import SwiftUI

struct TopNavBar: View {
    @Environment(\.colorScheme) private var colorScheme
    var hasCartBadge: Bool = true
    var onCartTap: () -> Void = {}

    var body: some View {
        let theme = theme(colorScheme)
        HStack {
            (
                Text("Home")
                    .foregroundStyle(theme.textPrimary)
                    .font(.largeTitle.bold())
            )
            .font(Theme.display(21, weight: .semibold, italic: true))

            Spacer()

            Button(action: onCartTap) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(theme.glassBackground)
                        .overlay(Circle().stroke(theme.glassBorder, lineWidth: 1))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "cart")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(theme.textPrimary)
                        )

                    if hasCartBadge {
                        Circle()
                            .fill(theme.madder)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(theme.background, lineWidth: 1.5))
                            .offset(x: 2, y: -2)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}

#Preview {
    TopNavBar()
}
