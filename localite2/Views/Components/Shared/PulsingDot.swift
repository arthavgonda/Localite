import SwiftUI

struct PulsingDot: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animate = false

    var body: some View {
        let color = theme(colorScheme).marigold
        ZStack {
            Circle()
                .stroke(color.opacity(animate ? 0 : 0.5), lineWidth: 3)
                .frame(width: animate ? 18 : 6, height: animate ? 18 : 6)
                .opacity(animate ? 0 : 1)
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
        }
        .frame(width: 18, height: 18)
        .onAppear {
            withAnimation(.easeOut(duration: 2.2).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

#Preview {
    PulsingDot().padding()
}
