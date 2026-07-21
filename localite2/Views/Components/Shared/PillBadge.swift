import SwiftUI

struct PillBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String
    var filled: Bool = true

    var body: some View {
        let theme = theme(colorScheme)
        Text(text)
            .font(Theme.mono(11.5, weight: .bold))
            .foregroundStyle(filled ? theme.textOnAccent : theme.marigold)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(filled ? theme.marigold : Color.clear)
            )
            .overlay(
                Capsule().stroke(theme.marigold, lineWidth: filled ? 0 : 1.5)
            )
    }
}

#Preview {
    VStack(spacing: 12) {
        PillBadge(text: "₹320")
        PillBadge(text: "+ Add PNR", filled: false)
    }
    .padding()
}
