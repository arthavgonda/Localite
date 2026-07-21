import SwiftUI

struct CustomTabBar: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selected: TabBarItemKind
    let mode: AppMode
    var onCenterTap: () -> Void = {}

    private let sideItems: [TabBarItemKind] = [.home, .explore, .cart, .profile]

    var body: some View {
        let theme = theme(colorScheme)
        HStack(alignment: .center, spacing: 20) {
            Spacer()
            ForEach(sideItems.prefix(2)) { item in
                tabButton(item, theme: theme)
            }

            centerButton(theme: theme)

            ForEach(sideItems.suffix(2)) { item in
                tabButton(item, theme: theme)
            }
            
            Spacer()
        }
//        .padding(.horizontal, 6)
//        .padding(.vertical, 10)
        .glassEffect()
        .shadow(color: theme.shadowColor, radius: 20, x: 0, y: 12)
    }

    private func tabButton(_ item: TabBarItemKind, theme: Theme) -> some View {
        Button {
            selected = item
        } label: {
            VStack(spacing: 4) {
                Image(systemName: item.symbolName)
                    .font(.system(size: 17, weight: .semibold))
                if let title = item.title {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .foregroundStyle(selected == item ? theme.marigold : theme.textSecondary)
            .frame(width: 44)
        }
        .buttonStyle(.plain)
    }

    private func centerButton(theme: Theme) -> some View {
        Button(action: onCenterTap) {
            Image(systemName: mode == .journey ? "checkmark" : TabBarItemKind.addJourney.symbolName)
                .font(.system(size: 35, weight: .semibold))
                .foregroundStyle(theme.textOnAccent)
                .frame(width: 60, height: 60)
//                .background(Circle().fill(theme.marigold))
                .glassEffect(.regular.tint(theme.marigold).interactive())
//                .overlay(Circle().stroke(theme.background.opacity(0.6)))
                .shadow(color: theme.marigold.opacity(0.6), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .offset(y: -15)
        .animation(.easeInOut(duration: 0.2), value: mode)
    }
}

#Preview {
    CustomTabBar(selected: .constant(.home), mode: .exploring)
        .padding()
}
