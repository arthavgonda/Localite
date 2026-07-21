import SwiftUI

struct GreetingHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    let greeting: String
    let locationLabel: String
    let mode: AppMode
    var onEndJourney: () -> Void = {}

    var body: some View {
        let theme = theme(colorScheme)
        VStack(alignment: .leading, spacing: 4) {

            HStack(spacing: 7) {
                (
                    Text(locationLabel)
                        .foregroundStyle(theme.textPrimary)
                        .fontWeight(.semibold)
                )
                .font(.system(size: 15))
            }
            .padding(.bottom, 18)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    GreetingHeaderView(
        greeting: "Good morning, Parth",
        locationLabel: "Connaught Place, Delhi",
        mode: .journey
    )
}
