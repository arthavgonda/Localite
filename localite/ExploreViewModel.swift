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
        span: MKCoordinateSpan(latitudeDelta: 30.0, longitudeDelta: 30.0)
    )
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
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
        // Optionally reset region to default here
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
            span: MKCoordinateSpan(latitudeDelta: 30.0, longitudeDelta: 30.0)
        )
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
            self.region = MKCoordinateRegion(center: center, span: span)
        }
    }
}
