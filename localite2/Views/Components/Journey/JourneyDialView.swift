import SwiftUI

struct JourneyDialView: View {
    @Environment(\.colorScheme) private var colorScheme
    let mode: AppMode
    let journeyInfo: JourneyInfo?
    let displayedMinutes: Int
    var onAddPNR: () -> Void = {}

    var body: some View {
        let theme = theme(colorScheme)
        VStack(alignment: .leading, spacing: 10) {
            if mode == .journey, let journeyInfo {
                Text("YOUR JOURNEY")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(theme.textOnCardSecondary)
                    .padding(.top, 10)
                
                Spacer()

                ZStack {
                    Circle()
                        .stroke(theme.textOnCard.opacity(0.12), lineWidth: 8)

                    Circle()
                        .trim(from: 0, to: journeyInfo.progress)
                        .stroke(theme.marigold, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1), value: journeyInfo.progress)

                    VStack(spacing: 1) {
                        Text("\(displayedMinutes)")
                            .font(Theme.mono(20, weight: .bold))
                            .foregroundStyle(theme.textOnCard)
                        Text("MIN LEFT")
                            .font(Theme.mono(8, weight: .semibold))
                            .foregroundStyle(theme.textOnCardSecondary)
                    }
                }
                .frame(width: 88, height: 88)
                .padding(.bottom, 15)
                
//                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Next")
                        .foregroundStyle(theme.textOnCard)
                        .font(.system(size: 10))
                    
                    Text("\(journeyInfo.destinationStation)")
                        .font(.system(size: 15, weight: .bold))
                        .lineLimit(2)
                        .foregroundStyle(theme.textOnCard)
                }
                .padding(.bottom, 5)
            } else {
                TrainTrackerIcon(theme: theme)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Track a train")
                    .font(Theme.display(14, weight: .semibold))
                    .foregroundStyle(theme.textOnCard)

                Text("Enter your PNR for live station stops")
                    .font(.system(size: 9.5))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(theme.textOnCardSecondary)
                    .frame(maxWidth: 110)

                Button(action: onAddPNR) {
                    PillBadge(text: "+ Add PNR")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 230)
        .background(theme.cardBackground)
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(theme.glassBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(theme.glassBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: theme.shadowColor, radius: 16, x: 0, y: 10)
        .animation(.easeInOut(duration: 0.3), value: mode)
    }
}

#Preview("Light — Journey") {
    JourneyDialView(mode: .journey, journeyInfo: .sample, displayedMinutes: 22)
        .frame(height: 230)
        .padding()
        .background(Theme(colorScheme: .light).background)
}

#Preview("Light — No Journey") {
    JourneyDialView(mode: .exploring, journeyInfo: nil, displayedMinutes: 0)
        .frame(height: 230)
        .padding()
        .background(Theme(colorScheme: .light).background)
}

#Preview("Dark") {
    JourneyDialView(mode: .journey, journeyInfo: .sample, displayedMinutes: 22)
        .frame(height: 230)
        .padding()
        .background(Theme(colorScheme: .dark).background)
        .preferredColorScheme(.dark)
}
