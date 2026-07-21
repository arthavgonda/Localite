import SwiftUI
import MapKit

private let pnrDigitCount = 10

private enum PNRActionState: Equatable {
    case hidden, find, loading, clear
}

private struct ZoomControlStack: View {
    let theme: Theme
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            zoomButton(icon: "plus", action: onZoomIn)
            Rectangle()
                .fill(theme.pageGlassBorder)
                .frame(width: 24, height: 1)
            zoomButton(icon: "minus", action: onZoomOut)
        }
        .glassEffect()
        .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 5)
    }

    private func zoomButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(theme.textPrimary)
                .frame(width: 40, height: 40)
        }
    }
}

private enum StationDirection {
    case previous, next

    var label: String {
        switch self {
        case .previous: "PREV STOP"
        case .next: "NEXT STOP"
        }
    }

    var icon: String {
        switch self {
        case .previous: "chevron.left"
        case .next: "chevron.right"
        }
    }
}

private struct AdjacentStationChip: View {
    let station: RouteStation
    let direction: StationDirection
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if direction == .previous {
                    Image(systemName: direction.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(theme.marigoldOnPage)
                }
                VStack(alignment: direction == .previous ? .leading : .trailing, spacing: 2) {
                    Text(direction.label)
                        .font(Theme.mono(8, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(theme.textSecondary)
                    Text(station.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(theme.textPrimary)
                }
                if direction == .next {
                    Image(systemName: direction.icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(theme.marigoldOnPage)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassEffect()
            .shadow(color: theme.shadowColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

private struct RouteStation: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let coordinate: CLLocationCoordinate2D
    let isTerminal: Bool

    static let sampleRoute: [RouteStation] = [
        RouteStation(name: "Delhi", detail: "Origin · 16:10", coordinate: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090), isTerminal: true),
        RouteStation(name: "Gwalior", detail: "+4h 40m", coordinate: CLLocationCoordinate2D(latitude: 26.2183, longitude: 78.1828), isTerminal: false),
        RouteStation(name: "Bhopal", detail: "+7h 55m", coordinate: CLLocationCoordinate2D(latitude: 23.2599, longitude: 77.4126), isTerminal: false),
        RouteStation(name: "Nagpur", detail: "+13h 20m", coordinate: CLLocationCoordinate2D(latitude: 21.1458, longitude: 79.0882), isTerminal: false),
        RouteStation(name: "Manmad", detail: "+18h 05m", coordinate: CLLocationCoordinate2D(latitude: 20.2539, longitude: 74.4377), isTerminal: false),
        RouteStation(name: "Kalyan", detail: "Arrival · +20h 30m", coordinate: CLLocationCoordinate2D(latitude: 19.2403, longitude: 73.1305), isTerminal: true)
    ]
}

private let idleCamera = MapCamera(
    centerCoordinate: CLLocationCoordinate2D(latitude: 23.6, longitude: 78.0),
    distance: 2_400_000,
    heading: 0,
    pitch: 0
)

private func fittingCamera(for coordinates: [CLLocationCoordinate2D], pitch: Double, minDistance: Double = 260_000) -> MapCamera {
    let lats = coordinates.map(\.latitude)
    let lons = coordinates.map(\.longitude)
    guard let minLat = lats.min(), let maxLat = lats.max(),
          let minLon = lons.min(), let maxLon = lons.max() else {
        return idleCamera
    }
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
    let span = max(maxLat - minLat, maxLon - minLon)
    let distance = max(span * 165_000, minDistance)
    return MapCamera(centerCoordinate: center, distance: distance, heading: 0, pitch: pitch)
}

struct PNRTrackScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @Namespace private var headerMorph

    @State private var pnrInput: String = ""
    @State private var trackState: TrackState = .idle
    @State private var errorMessage: String?
    @State private var cameraPosition: MapCameraPosition = .camera(idleCamera)
    
    @State private var liveCameraDistance: Double = idleCamera.distance
    @State private var mapCenterCoordinate: CLLocationCoordinate2D = idleCamera.centerCoordinate

    private let deepZoomThreshold: Double = 60_000
    private let zoomStep: Double = 0.6
    private let minCameraDistance: Double = 1500
    private let maxCameraDistance: Double = 2_800_000

    var onDecode: (String) -> Void = { _ in }

    private let stations = RouteStation.sampleRoute

    private enum TrackState { case idle, loading, revealed }

    private var digits: [String] {
        var padded = Array(pnrInput.prefix(pnrDigitCount)).map { String($0) }
        while padded.count < pnrDigitCount { padded.append("") }
        return padded
    }
    
    private var nearestStationIndex: Int? {
        guard !stations.isEmpty else { return nil }
        let center = CLLocation(latitude: mapCenterCoordinate.latitude, longitude: mapCenterCoordinate.longitude)
        return stations.indices.min { a, b in
            let da = CLLocation(latitude: stations[a].coordinate.latitude, longitude: stations[a].coordinate.longitude).distance(from: center)
            let db = CLLocation(latitude: stations[b].coordinate.latitude, longitude: stations[b].coordinate.longitude).distance(from: center)
            return da < db
        }
    }
    
    private var previousStationIndex: Int? {
        guard trackState == .revealed, let nearest = nearestStationIndex else { return nil }
        let prev = nearest - 1
        return prev >= 0 ? prev : nil
    }

    private var nextStationIndex: Int? {
        guard trackState == .revealed, let nearest = nearestStationIndex else { return nil }
        let next = nearest + 1
        return next < stations.count ? next : nil
    }

    private var isDeepZoomed: Bool { liveCameraDistance < deepZoomThreshold }
    
    private func focus(on station: RouteStation) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: station.coordinate, distance: liveCameraDistance, heading: 0, pitch: 58))
        }
    }

    private func zoom(by factor: Double) {
        let newDistance = min(max(liveCameraDistance * factor, minCameraDistance), maxCameraDistance)
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: mapCenterCoordinate, distance: newDistance, heading: 0, pitch: trackState == .revealed ? 58 : 0))
        }
    }

    private var isComplete: Bool { pnrInput.count == pnrDigitCount }

    private var buttonState: PNRActionState {
        if trackState == .loading { return .loading }
        if trackState == .revealed { return .clear }
        if isComplete { return .find }
        return .hidden
    }

    var body: some View {
        let theme = theme(colorScheme)

        ZStack(alignment: .top) {
            Map(position: $cameraPosition, interactionModes: trackState == .revealed ? .all : []) {
                if trackState == .revealed {
                    ForEach(stations) { station in
                        Annotation(station.name, coordinate: station.coordinate) {
                            StationMarker(station: station, theme: theme)
                        }
                    }
                    MapPolyline(coordinates: stations.map(\.coordinate))
                        .stroke(theme.marigoldOnPage, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                }
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll))
            .saturation(trackState == .revealed ? 1 : 0.2)
            .brightness(trackState == .revealed ? 0 : -0.03)
            .ignoresSafeArea()
            .onMapCameraChange(frequency: .continuous) { context in
                liveCameraDistance = context.camera.distance
                mapCenterCoordinate = context.camera.centerCoordinate
            }

            VStack {
                if trackState == .idle {
                    RouteNoteBanner(
                        icon: "info.circle.fill",
                        tint: theme.marigoldOnPage,
                        message: "Enter Your PNR to see the stations along your route.",
                        theme: theme
                    )
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .transition(.opacity)
                } else if trackState == .revealed {
                    RouteNoteBanner(
                        icon: "checkmark.circle.fill",
                        tint: theme.marigoldOnPage,
                        message: "Tap any pin for that station's local specialty along your route.",
                        theme: theme
                    )
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .transition(.opacity)
                }
                
                if trackState == .revealed {
                    HStack {
                        ZoomControlStack(
                            theme: theme,
                            onZoomIn: { zoom(by: zoomStep) },
                            onZoomOut: { zoom(by: 1 / zoomStep) }
                        )
                        .padding(.leading, 14)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 10) {
                            if isDeepZoomed, let idx = previousStationIndex {
                                AdjacentStationChip(station: stations[idx], direction: .previous, theme: theme) {
                                    focus(on: stations[idx])
                                }
                            }
                            if isDeepZoomed, let idx = nextStationIndex {
                                AdjacentStationChip(station: stations[idx], direction: .next, theme: theme) {
                                    focus(on: stations[idx])
                                }
                            }
                        }
                        .padding(.trailing, 14)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isDeepZoomed)
                }
                Spacer()
            }
            .animation(.easeInOut(duration: 0.4), value: trackState)
        }
        .safeAreaInset(edge: .top) {
            headerContent(theme: theme)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { isFocused = true }
        .onChange(of: trackState) { _, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.86)) {
                cameraPosition = newValue == .revealed
                    ? .camera(fittingCamera(for: stations.map(\.coordinate), pitch: 58))
                    : .camera(idleCamera)
            }
        }
    }

    @ViewBuilder
    private func headerContent(theme: Theme) -> some View {
        Group {
            if trackState == .revealed {
                CollapsedHeader(
                    digits: digits,
                    buttonState: buttonState,
                    namespace: headerMorph,
                    theme: theme,
                    onBack: { dismiss() },
                    onAction: handleAction
                )
            } else {
                ExpandedHeader(
                    pnrInput: $pnrInput,
                    digits: digits,
                    isFocused: $isFocused,
                    buttonState: buttonState,
                    errorMessage: errorMessage,
                    namespace: headerMorph,
                    theme: theme,
                    onBack: { dismiss() },
                    onAction: handleAction
                )
            }
        }
//        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.pageGlassBorder)
                .frame(height: 1)
        }
    }

    private func handleAction() {
        switch buttonState {
        case .find:
            submit()
        case .clear:
            reset()
        case .hidden, .loading:
            break
        }
    }

    private func submit() {
        guard isComplete else { return }
        isFocused = false
        errorMessage = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            trackState = .loading
        }
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            await MainActor.run {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                    trackState = .revealed
                }
            }
            onDecode(pnrInput)
        }
    }

    private func reset() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            trackState = .idle
        }
        pnrInput = ""
        errorMessage = nil
        isFocused = true
    }
}

// MARK: - Expanded (idle) header — one continuous ticket

private struct ExpandedHeader: View {
    @Binding var pnrInput: String
    let digits: [String]
    var isFocused: FocusState<Bool>.Binding
    let buttonState: PNRActionState
    let errorMessage: String?
    let namespace: Namespace.ID
    let theme: Theme
    let onBack: () -> Void
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                BackButton(theme: theme, action: onBack)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)

//            VStack(alignment: .leading, spacing: 6) {
//                Text("Track your journey")
//                    .font(Theme.display(22, italic: true))
//                    .foregroundStyle(theme.textPrimary)
//                Text("Enter your 10-digit PNR and we'll decode your route.")
//                    .font(.system(size: 12.5))
//                    .foregroundStyle(theme.textSecondary)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 22)

            TicketCard(
                pnrInput: $pnrInput,
                digits: digits,
                isFocused: isFocused,
                buttonState: buttonState,
                errorMessage: errorMessage,
                namespace: namespace,
                theme: theme,
                onAction: onAction
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
    }
}

private struct TicketCard: View {
    @Binding var pnrInput: String
    let digits: [String]
    var isFocused: FocusState<Bool>.Binding
    let buttonState: PNRActionState
    let errorMessage: String?
    let namespace: Namespace.ID
    let theme: Theme
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ticketTop
            TicketPerforation()
            ticketBottom
        }
        .compositingGroup()
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: theme.shadowColor, radius: 18, x: 0, y: 10)
    }

    private var ticketTop: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("LOCALITE EXPRESS")
                    .font(Theme.mono(10, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(theme.marigold)
                Spacer()
                Image(systemName: "tram.fill")
                    .foregroundStyle(theme.marigold)
            }
            HStack(spacing: 10) {
                Text("Delhi")
                    .font(Theme.display(16, weight: .semibold))
                    .foregroundStyle(theme.textOnCard)
                ZStack {
                    Rectangle()
                        .fill(theme.textOnCard.opacity(0.25))
                        .frame(height: 2)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.marigold)
                        .background(theme.cardBackground)
                }
                Text("Kalyan")
                    .font(Theme.display(16, weight: .semibold))
                    .foregroundStyle(theme.textOnCard)
            }
            Text("We'll surface what's local at every stop along the way")
                .font(.system(size: 10.5))
                .foregroundStyle(theme.textOnCardSecondary)
        }
        .padding(18)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
    }

    private var ticketBottom: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ENTER PNR")
                .font(Theme.mono(10, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(theme.textSecondary)

            HStack(spacing: 6) {
                ForEach(0..<pnrDigitCount, id: \.self) { index in
                    DigitBox(
                        value: digits[index],
                        isActive: isFocused.wrappedValue && digits.filter { !$0.isEmpty }.count == index,
                        isError: errorMessage != nil,
                        compact: false,
                        theme: theme
                    )
                    .matchedGeometryEffect(id: "digit-\(index)", in: namespace)
                }
            }
            .background(
                TextField("", text: Binding(
                    get: { pnrInput },
                    set: { newValue in
                        pnrInput = String(newValue.filter(\.isNumber).prefix(pnrDigitCount))
                    }
                ))
                .keyboardType(.numberPad)
                .focused(isFocused)
                .opacity(0.01)
            )
            .contentShape(Rectangle())
            .onTapGesture { isFocused.wrappedValue = true }

            HStack(alignment: .top) {
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 11.5))
                        .foregroundStyle(theme.madder)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Find this on your ticket or SMS")
                        .font(.system(size: 11.5))
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
                PNRActionButton(state: buttonState, theme: theme, action: onAction)
                    .matchedGeometryEffect(id: "actionButton", in: namespace)
            }
        }
        .padding(18)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.background)
    }
}

private struct TicketPerforation: View {
    private let dotSize: CGFloat = 9
    private let spacing: CGFloat = 11

    var body: some View {
        GeometryReader { geo in
            let count = max(Int(geo.size.width / (dotSize + spacing)), 1)
            HStack(spacing: spacing) {
                ForEach(0..<count, id: \.self) { _ in
                    Circle().frame(width: dotSize, height: dotSize)
                }
            }
            .frame(width: geo.size.width, alignment: .center)
            .overlay(alignment: .leading) {
                Circle().frame(width: 22, height: 22).offset(x: -11)
            }
            .overlay(alignment: .trailing) {
                Circle().frame(width: 22, height: 22).offset(x: 11)
            }
        }
        .frame(height: 20)
        .blendMode(.destinationOut)
    }
}

// MARK: - Collapsed (revealed) header — sticky PNR-only strip

private struct CollapsedHeader: View {
    let digits: [String]
    let buttonState: PNRActionState
    let namespace: Namespace.ID
    let theme: Theme
    let onBack: () -> Void
    let onAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            BackButton(theme: theme, action: onBack)

            HStack(spacing: 4) {
                ForEach(0..<pnrDigitCount, id: \.self) { index in
                    DigitBox(
                        value: digits[index],
                        isActive: false,
                        isError: false,
                        compact: true,
                        theme: theme
                    )
                    .matchedGeometryEffect(id: "digit-\(index)", in: namespace)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(theme.background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(theme.pageGlassBorder, lineWidth: 1)
            )

            PNRActionButton(state: buttonState, theme: theme, action: onAction)
                .matchedGeometryEffect(id: "actionButton", in: namespace)
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}

// MARK: - Shared pieces

private struct DigitBox: View {
    let value: String
    let isActive: Bool
    let isError: Bool
    let compact: Bool
    let theme: Theme

    var body: some View {
        Text(value)
            .font(Theme.mono(compact ? 12 : 18, weight: .bold))
            .foregroundStyle(theme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: compact ? 28 : 46)
            .background(theme.textPrimary.opacity(0.03))
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 7 : 12, style: .continuous)
                    .stroke(borderColor, lineWidth: isActive || isError ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: compact ? 7 : 12, style: .continuous))
            .shadow(
                color: isActive ? theme.marigold.opacity(0.25) : .clear,
                radius: isActive ? 4 : 0
            )
    }

    private var borderColor: Color {
        if isError { return theme.madder }
        if isActive { return theme.marigold }
        if !value.isEmpty { return theme.textPrimary.opacity(0.18) }
        return theme.pageGlassBorder
    }
}

private struct PNRActionButton: View {
    let state: PNRActionState
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Group {
            switch state {
            case .hidden:
                Color.clear
                    .frame(width: 1, height: 1)
            case .loading:
                ProgressView()
                    .tint(theme.textOnCard)
                    .frame(width: 44, height: 44)
                    .background(theme.cardBackground)
                    .clipShape(Circle())
            case .find:
                Button(action: action) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(theme.textOnAccent)
                        .frame(width: 44, height: 44)
                        .background(theme.marigold)
                        .clipShape(Circle())
                        .shadow(color: theme.marigold.opacity(0.35), radius: 8, x: 0, y: 4)
                }
            case .clear:
                Button(action: action) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(theme.madder)
                        .frame(width: 44, height: 44)
                        .glassEffect()
                        .clipShape(Circle())
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: state)
        .transition(.scale.combined(with: .opacity))
    }
}

private struct BackButton: View {
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(theme.textPrimary)
                .frame(width: 36, height: 36)
                .glassEffect()
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(theme.pageGlassBorder, lineWidth: 1)
                )
        }
    }
}

private struct StationMarker: View {
    let station: RouteStation
    let theme: Theme

    var body: some View {
        VStack(spacing: 4) {
            VStack(spacing: 2) {
                Text(station.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
                Text(station.detail)
                    .font(Theme.mono(8.5, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .glassEffect()
            .shadow(color: theme.shadowColor, radius: 6, x: 0, y: 3)

            Circle()
                .fill(station.isTerminal ? theme.marigoldOnPage : theme.cardBackground)
                .frame(width: station.isTerminal ? 13 : 9, height: station.isTerminal ? 13 : 9)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2.5)
                )
        }
    }
}

private struct RouteNoteBanner: View {
    let icon: String
    let tint: Color
    let message: String
    let theme: Theme

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .padding(.top, 1)
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(theme.textPrimary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(theme.pageGlassBorder, lineWidth: 1)
        )
    }
}

#Preview("Idle — Light") {
    NavigationStack {
        PNRTrackScreen()
    }
}

#Preview("Idle — Dark") {
    NavigationStack {
        PNRTrackScreen()
    }
    .preferredColorScheme(.dark)
}
