import SwiftUI
import MapKit

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showingPNREntry = true
    @State private var sheetDetent: PresentationDetent = .height(190)
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottomTrailing) {
                MapViewRepresentable(region: $viewModel.region, journey: viewModel.currentJourney)
                    .ignoresSafeArea(edges: .top)
                
                // Search button to bring back the PNR sheet if it was closed
                if !showingPNREntry {
                    Button(action: {
                        showingPNREntry = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingPNREntry) {
                if #available(iOS 16.0, *) {
                    PNREntryView(viewModel: viewModel, detent: $sheetDetent)
                        .presentationDetents([.height(200), .medium, .large], selection: $sheetDetent)
                        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                        .interactiveDismissDisabled()
                } else {
                    // Fallback for older iOS versions
                    PNREntryView(viewModel: viewModel, detent: .constant(.medium))
                }
            }
        }
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var journey: Journey?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        
        // Remove existing overlays and annotations
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        if let journey = journey {
            var coordinates = journey.stations.map { $0.coordinate }
            
            // Add Polyline
            let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            uiView.addOverlay(polyline)
            
            // Add Annotations
            for station in journey.stations {
                let annotation = MKPointAnnotation()
                annotation.coordinate = station.coordinate
                annotation.title = station.name
                uiView.addAnnotation(annotation)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
