import Foundation
import CoreLocation
import MapKit
import Combine
import SwiftUI

class ExploreViewModel: ObservableObject {
    @Published var pnrInput: String = ""
    @Published var currentJourney: Journey?
    @Published var selectedStation: Station?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629), // Center of India
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    )
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Shared UI state
    // Hoisted out of ExploreView so the app-level tab bar (RootTabView) can
    // drive them too — e.g. dismissing the PNR sheet and recentering the map
    // when the user taps "Home" from the morphing tab bar.
    @Published var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
        latitudinalMeters: 1000,
        longitudinalMeters: 1000
    ))
    @Published var showBottomSheet: Bool = true
    @Published var sheetDetent: PresentationDetent = .height(80)
    @Published var sheetHeight: CGFloat = 0
    @Published var toolbarOpacity: CGFloat = 1
    @Published var toolbarAnimationDuration: CGFloat = 0

    var isValidPNR: Bool {
        // A valid PNR is 10 digits
        return pnrInput.count == 10 && pnrInput.allSatisfy { $0.isNumber }
    }
    
    private let allJourneys: [Journey]
    
    init() {
        self.allJourneys = loadDummyJourneys()
    }
    
    func searchJourney() {
        if let journey = allJourneys.first(where: { $0.pnr == pnrInput }) {
            currentJourney = journey
            focusOnJourney(journey)
            showError = false
        } else {
            showError = true
            errorMessage = "No journey found for PNR \(pnrInput)"
        }
    }
    
    func clearJourney() {
        currentJourney = nil
        pnrInput = ""
        showError = false
        position = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        ))
    }
    
    /// Called when the user taps "Home" in the morphing tab bar. Resets
    /// everything about the Explore tab — dismisses the PNR sheet, clears any
    /// active journey, and recenters the map — so the next time they come
    /// back to Explore it's in a clean state, and no sheet leaks onto Home.
    func goHome() {
        showBottomSheet = false
        sheetDetent = .height(80)
        selectedStation = nil
        clearJourney()
    }

    /// Called when the user taps the map icon while already on the Explore
    /// tab — recenters on the device's current location.
    func recenterOnUser() {
        position = .userLocation(fallback: .automatic)
    }

    private func focusOnJourney(_ journey: Journey) {
        guard !journey.stations.isEmpty else { return }
        
        let latitudes = journey.stations.map { $0.latitude }
        let longitudes = journey.stations.map { $0.longitude }
        
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else { return }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2.0,
            longitude: (minLon + maxLon) / 2.0
        )
        
        let latDelta = maxLat - minLat
        let lonDelta = maxLon - minLon
        
        // Use a 20% padding by default
        var paddingFactor = 1.2
        
        // If it's a very long journey, use tighter padding
        if latDelta > 5.0 || lonDelta > 5.0 {
            paddingFactor = 1.1
        }
        
        // Ensure a minimum zoom level for very short journeys
        let minSpan: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(latDelta * paddingFactor, minSpan),
            longitudeDelta: max(lonDelta * paddingFactor, minSpan)
        )
        
        DispatchQueue.main.async {
            self.position = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        // Request permission
        manager.requestWhenInUseAuthorization()
        // Start updating location to show the dot
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }
}
