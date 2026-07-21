import SwiftUI

struct SectionTitle: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(theme(colorScheme).textPrimary)
            .padding(.top, 15)
            .padding(.bottom, 5)
            .padding(.leading, -170)
    }
}

#Preview {
    SectionTitle(text: "Browse by category")
}
