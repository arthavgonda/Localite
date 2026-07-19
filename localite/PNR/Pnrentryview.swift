//
//  Pnrentryview.swift
//  localite
//
//  Created by ANOOP on 19/07/26.
//

import SwiftUI
import Lottie
import MapKit

struct PNREntryView: View {
    @ObservedObject var viewModel: ExploreViewModel
    @Binding var detent: PresentationDetent
    @State private var localSelectedStation: Station?
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var locationStore: LocationStore

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if let journey = viewModel.currentJourney {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(journey.trainName) (\(journey.trainNumber))")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(LocaliteTheme.ink)

                        Text("Choose a station for delivery")
                            .font(.subheadline)
                            .foregroundStyle(LocaliteTheme.inkSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 6)

                    VStack(spacing: 0) {
                        ForEach(Array(journey.stations.enumerated()), id: \.element.id) { index, station in
                            Button {
                                localSelectedStation = station
                            } label: {
                                StationTimelineRow(
                                    station: station,
                                    status: status(for: index),
                                    isFirst: index == 0,
                                    isLast: index == journey.stations.count - 1
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            } else if viewModel.showError {
                VStack {
                    Spacer().frame(height: 40)
                    Text(viewModel.errorMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(LocaliteTheme.accent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                VStack {
                    Spacer().frame(height: 60)
                    LottieView(name: "Portal")
                        .frame(width: 200, height: 200)
                        .padding(.bottom, 20)

                    Text("Enter your 10-digit PNR to track your journey and order local items.")
                        .font(.subheadline)
                        .foregroundStyle(LocaliteTheme.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            searchBar
        }
        .sheet(item: $localSelectedStation) { station in
            TopPicksView(station: station)
        }
    }

    private func status(for index: Int) -> StationTimelineRow.Status {
        if index == 0 { return .departed }
        if index == 1 { return .next }
        return .upcoming
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            locationIndicator

            HStack(spacing: 10) {
                Image(systemName: "train.side.front.car")
                    .font(.subheadline)
                    .foregroundStyle(LocaliteTheme.accent)

                TextField("Enter 10-digit PNR", text: $viewModel.pnrInput)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(LocaliteTheme.ink)
                    .onChange(of: viewModel.pnrInput) { _, newValue in
                        if newValue.isEmpty && viewModel.currentJourney != nil {
                            viewModel.clearJourney()
                        }
                        if viewModel.showError {
                            viewModel.showError = false
                        }
                    }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(LocaliteTheme.surfaceMuted, in: Capsule())

            if viewModel.isValidPNR {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        viewModel.searchJourney()
                        isFocused = false
                        detent = .height(350)
                    }
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(LocaliteTheme.accent, in: Circle())
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity).combined(with: .move(edge: .trailing)),
                    removal: .scale.combined(with: .opacity)
                ))
            }

            if isFocused || detent != .height(80) || !viewModel.pnrInput.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.clearJourney()
                        isFocused = false
                        detent = .height(80)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(LocaliteTheme.ink)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 0.5))
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.pnrInput.isEmpty)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.isValidPNR)
        .padding(.horizontal, 18)
        .frame(height: 80)
        .padding(.top, 5)
    }

    private var locationIndicator: some View {
        Button {
            withAnimation {
                viewModel.position = .region(MKCoordinateRegion(
                    center: locationStore.selected.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                ))
            }
        } label: {
            ZStack {
                if locationStore.selected.isLive {
                    Circle()
                        .fill(Color.blue.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2.5)
                        )
                        .shadow(color: .blue.opacity(0.4), radius: 4)
                } else {
                    Circle()
                        .fill(LocaliteTheme.surfaceMuted)
                        .frame(width: 40, height: 40)
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(LocaliteTheme.accent)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct StationTimelineRow: View {
    enum Status {
        case departed
        case next
        case upcoming
    }

    let station: Station
    let status: Status
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            timelineColumn
            content
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(status == .next ? LocaliteTheme.accent : LocaliteTheme.inkMuted)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, status == .next ? 10 : 0)
        .background(
            status == .next ? LocaliteTheme.accent.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var timelineColumn: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : LocaliteTheme.hairline)
                .frame(width: 1.5)
                .frame(maxHeight: .infinity)

            dot

            Rectangle()
                .fill(isLast ? Color.clear : LocaliteTheme.hairline)
                .frame(width: 1.5)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 28)
    }

    @ViewBuilder
    private var dot: some View {
        switch status {
        case .departed:
            ZStack {
                Circle().fill(LocaliteTheme.ink)
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 28, height: 28)
        case .next:
            ZStack {
                Circle().fill(LocaliteTheme.accent)
                Image(systemName: "mappin")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 28, height: 28)
        case .upcoming:
            ZStack {
                Circle()
                    .strokeBorder(LocaliteTheme.hairline, lineWidth: 1.5)
                Text(station.code)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(LocaliteTheme.inkMuted)
            }
            .frame(width: 28, height: 28)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(station.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(LocaliteTheme.ink)

            if status == .next {
                Text("Next stop · \(station.arrivalTime)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(LocaliteTheme.accent)
            } else {
                Text(station.arrivalTime)
                    .font(.caption)
                    .foregroundStyle(LocaliteTheme.inkSecondary)
            }
        }
    }
}

// MARK: - Lottie View Wrapper
struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat

    init(name: String, loopMode: LottieLoopMode = .loop, animationSpeed: CGFloat = 1.0) {
        self.name = name
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        if let asset = NSDataAsset(name: name),
           let animation = try? LottieAnimation.from(data: asset.data) {
            animationView.animation = animation
        }

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    VStack(spacing: 0) {
        StationTimelineRow(
            station: Station(name: "New Delhi", code: "NDLS", arrivalTime: "18 Jul, 4:00 PM", latitude: 28.6, longitude: 77.2),
            status: .departed,
            isFirst: true,
            isLast: false
        )
        StationTimelineRow(
            station: Station(name: "Mathura Junction", code: "MTJ", arrivalTime: "18 Jul, 5:15 PM", latitude: 27.4, longitude: 77.6),
            status: .next,
            isFirst: false,
            isLast: false
        )
        StationTimelineRow(
            station: Station(name: "Agra Cantt", code: "AGC", arrivalTime: "18 Jul, 6:00 PM", latitude: 27.1, longitude: 78.0),
            status: .upcoming,
            isFirst: false,
            isLast: true
        )
    }
    .padding(.horizontal, 20)
}
