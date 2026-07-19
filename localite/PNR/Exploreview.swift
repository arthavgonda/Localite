import SwiftUI
import MapKit

struct ExploreView: View {
    @ObservedObject var viewModel: ExploreViewModel
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var locationStore: LocationStore
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Map(position: $viewModel.position, selection: $viewModel.selectedStation) {
                UserAnnotation()

                if let journey = viewModel.currentJourney {
                    MapPolyline(coordinates: journey.stations.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 4)

                    ForEach(journey.stations) { station in
                        Marker(station.name, systemImage: "tram.fill", coordinate: station.coordinate)
                            .tag(station)
                    }
                }
            }
            .onChange(of: viewModel.currentJourney?.id) { _ in
                if let journey = viewModel.currentJourney, !journey.stations.isEmpty {
                    var rect = MKMapRect.null
                    for station in journey.stations {
                        let point = MKMapPoint(station.coordinate)
                        let stationRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
                        rect = rect.isNull ? stationRect : rect.union(stationRect)
                    }
                    withAnimation {
                        viewModel.position = .rect(rect.insetBy(dx: -50000, dy: -50000))
                    }
                }
            }
            .onChange(of: viewModel.selectedStation) { station in
                withAnimation {
                    viewModel.showBottomSheet = (station == nil)
                }
            }
            .sheet(isPresented: $viewModel.showBottomSheet) {
                PNREntryView(viewModel: viewModel, detent: $viewModel.sheetDetent)
                    .environmentObject(locationStore)
                    .presentationDetents([.height(80), .height(350), .large], selection: $viewModel.sheetDetent)
                    .presentationBackground(.regularMaterial)
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        max(min(proxy.size.height, 350), 0)
                    } action: { oldValue, newValue in
                        viewModel.sheetHeight = min(newValue, 300)

                        let progress = max(min((newValue - 300) / 50, 1), 0)
                        viewModel.toolbarOpacity = 1 - progress

                        let diff = abs(newValue - oldValue)
                        let duration = max(min(diff / 100, 0.3), 0)
                        viewModel.toolbarAnimationDuration = duration
                    }
                    .ignoresSafeArea()
            }
            .sheet(item: $viewModel.selectedStation) { station in
                TopPicksView(station: station)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            Button(action: onBack) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LocaliteTheme.ink)
                    .frame(width: 44, height: 44)
                    .background(Color.white, in: Circle())
                    .overlay(Circle().strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.top, 8)
        }
        .onAppear {
            if viewModel.currentJourney == nil {
                viewModel.showBottomSheet = true
            }
        }
    }
}

#Preview {
    ExploreView(viewModel: ExploreViewModel(), onBack: {})
}
