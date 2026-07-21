import SwiftUI

struct RouteMapView: View {
    @Environment(\.colorScheme) private var colorScheme
    let mode: AppMode
    let journeyInfo: JourneyInfo?
    let curatedRegionsCount: Int
    var onExpand: () -> Void = {}

    @State private var pathProgress: CGFloat = 0
    @State private var dashPhase: CGFloat = 0

    var body: some View {
        let theme = theme(colorScheme)
        ZStack(alignment: .topLeading) {
            (theme.isDark ? Color(hex: "171310") : Color(hex: "FFFFF7"))

            GridPattern()
                .stroke(theme.textPrimary.opacity(0.05), lineWidth: 1)

            if mode == .journey, let journeyInfo {
                RoutePath()
                    .trim(from: 0, to: pathProgress)
                    .stroke(theme.marigold, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 7], dashPhase: dashPhase))
                    .onAppear {
                        pathProgress = 0
                        withAnimation(.easeOut(duration: 0.9)) {
                            pathProgress = 1
                        }
                        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                            dashPhase = -16
                        }
                    }
                RouteDots(highlightColor: theme.marigold, mutedColor: theme.textPrimary.opacity(0.4))

                VStack(alignment: .leading, spacing: 3) {
                    Text("ALONG YOUR ROUTE")
                        .font(Theme.mono(12, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(theme.marigold)

                    Text("\(journeyInfo.stationsAlongRoute) stations · \(journeyInfo.regionalSpecialtiesCount) regional specialties")
                        .font(Theme.display(15, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                }
                .padding(14)
            } else {
                ExploreRadar(color: theme.marigold, mutedColor: theme.textPrimary.opacity(0.55))

                VStack(alignment: .leading, spacing: 3) {
                    Text("SOURCED FOR YOU")
                        .font(Theme.mono(12, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(theme.marigold)

                    Text("This week, curated from \(curatedRegionsCount) regions")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(theme.textPrimary)
                }
                .padding(14)
            }

            Button(action: onExpand) {
                Circle()
                    .fill(theme.glassBackground)
                    .overlay(Circle().stroke(theme.glassBorder, lineWidth: 1))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(theme.textPrimary)
                    )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(14)
        }
        .frame(height: 118)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(theme.glassBorder, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: mode)
    }
}

private struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        stride(from: 0, through: rect.width, by: 20).forEach { x in
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        stride(from: 0, through: rect.height, by: 20).forEach { y in
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

private struct RoutePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: 0.06 * w, y: 0.76 * h))
        path.addQuadCurve(to: CGPoint(x: 0.51 * w, y: 0.51 * h),
                           control: CGPoint(x: 0.29 * w, y: 0.17 * h))
        path.addQuadCurve(to: CGPoint(x: 0.94 * w, y: 0.25 * h),
                           control: CGPoint(x: 0.72 * w, y: 0.68 * h))
        return path
    }
}

private struct RouteDots: View {
    let highlightColor: Color
    let mutedColor: Color

    @State private var pulse = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height

            Circle().fill(mutedColor).frame(width: 8, height: 8)
                .position(x: 0.06 * w, y: 0.76 * h)

            Circle()
                .stroke(highlightColor.opacity(0.5), lineWidth: 1)
                .frame(width: 10, height: 10)
                .scaleEffect(pulse ? 2.4 : 1)
                .opacity(pulse ? 0 : 0.8)
                .position(x: 0.51 * w, y: 0.51 * h)

            Circle().fill(highlightColor).frame(width: 10, height: 10)
                .position(x: 0.51 * w, y: 0.51 * h)

            Circle().fill(mutedColor.opacity(0.5)).frame(width: 8, height: 8)
                .position(x: 0.94 * w, y: 0.25 * h)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

private struct ExploreRadar: View {
    let color: Color
    let mutedColor: Color

    @State private var ringPulse = false
    @State private var dotsVisible = false

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
            ZStack {
                Circle()
                    .stroke(color.opacity(0.4), lineWidth: 1)
                    .frame(width: 52, height: 52)
                    .scaleEffect(ringPulse ? 1.7 : 1)
                    .opacity(ringPulse ? 0 : 0.6)
                    .position(center)

                Circle().stroke(color.opacity(0.2), lineWidth: 1).frame(width: 52, height: 52).position(center)
                Circle().stroke(color.opacity(0.4), lineWidth: 1).frame(width: 28, height: 28).position(center)
                Circle().fill(color).frame(width: 10, height: 10).position(center)

                ForEach(Array(scatterPoints(in: geo.size).enumerated()), id: \.offset) { index, point in
                    Circle().fill(mutedColor).frame(width: 7, height: 7).position(point)
                        .scaleEffect(dotsVisible ? 1 : 0.3)
                        .opacity(dotsVisible ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.07), value: dotsVisible)
                }
            }
            .onAppear {
                dotsVisible = true
                withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                    ringPulse = true
                }
            }
        }
    }

    private func scatterPoints(in size: CGSize) -> [CGPoint] {
        [
            CGPoint(x: size.width * 0.31, y: size.height * 0.34),
            CGPoint(x: size.width * 0.69, y: size.height * 0.30),
            CGPoint(x: size.width * 0.26, y: size.height * 0.72),
            CGPoint(x: size.width * 0.73, y: size.height * 0.76),
            CGPoint(x: size.width * 0.43, y: size.height * 0.81)
        ]
    }
}

#Preview {
    RouteMapView(mode: .exploring, journeyInfo: nil, curatedRegionsCount: 4).padding()
}
