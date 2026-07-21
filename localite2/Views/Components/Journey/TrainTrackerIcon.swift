import SwiftUI

struct TrainTrackerIcon: View {
    let theme: Theme

    @State private var trigger = false

    private let iconDiameter: CGFloat = 40
    private let overflow: CGFloat = 32
    private let trackOffset: CGFloat = 6

    private enum Phase: CaseIterable {
        case idle, spin, toLine, travel, toCircle
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let leadingX = iconDiameter / 2
            let trailingX = width - iconDiameter / 2
            let travelDistance = width + iconDiameter + 24
            let circleY = height / 2

            PhaseAnimator(Phase.allCases, trigger: trigger) { phase in
                ZStack(alignment: .leading) {
                    MorphingStrokeShape(
                        progress: lineProgress(phase),
                        diameter: iconDiameter,
                        overflow: overflow,
                        trackOffset: trackOffset
                    )
                    .stroke(theme.marigold.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4]))
                    .rotationEffect(.degrees(rotation(phase)), anchor: UnitPoint(x: leadingX / max(width, 1), y: 0.5))

                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.marigold)
                        .position(x: outboundTrainX(phase, leadingX: leadingX, distance: travelDistance), y: circleY)

                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.marigold)
                        .position(x: inboundTrainX(phase, leadingX: leadingX, distance: travelDistance), y: circleY)
                }
            } animation: { phase in
                animation(phase)
            }
            .frame(width: width, height: height)
        }
        .frame(height: iconDiameter + trackOffset)
        .onAppear { trigger.toggle() }
    }

    private func rotation(_ phase: Phase) -> Double {
        phase == .idle ? 0 : 360
    }

    private func lineProgress(_ phase: Phase) -> CGFloat {
        switch phase {
        case .idle, .spin, .toCircle: return 0
        case .toLine, .travel: return 1
        }
    }

    private func outboundTrainX(_ phase: Phase, leadingX: CGFloat, distance: CGFloat) -> CGFloat {
        switch phase {
        case .idle, .spin, .toLine: return leadingX
        case .travel, .toCircle: return leadingX + distance
        }
    }

    private func inboundTrainX(_ phase: Phase, leadingX: CGFloat, distance: CGFloat) -> CGFloat {
        switch phase {
        case .idle, .spin, .toLine: return leadingX - distance
        case .travel, .toCircle: return leadingX
        }
    }

    private func animation(_ phase: Phase) -> Animation {
        switch phase {
        case .idle: return .linear(duration: 0)
        case .spin: return .easeInOut(duration: 0.85)
        case .toLine: return .easeInOut(duration: 0.55)
        case .travel: return .interpolatingSpring(mass: 0.6, stiffness: 55, damping: 13, initialVelocity: 1.5)
        case .toCircle: return .easeInOut(duration: 0.55)
        }
    }
}
