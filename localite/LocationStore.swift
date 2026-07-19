import SwiftUI
import CoreLocation
import MapKit
import Combine

struct AppLocation: Identifiable, Equatable {
    let id: UUID
    let name: String
    let shortName: String
    let coordinate: CLLocationCoordinate2D
    var isLive: Bool = false

    static func == (lhs: AppLocation, rhs: AppLocation) -> Bool { lhs.id == rhs.id }

    static let presets: [AppLocation] = [
        AppLocation(id: UUID(), name: "Connaught Place, New Delhi", shortName: "Connaught Place",
                    coordinate: CLLocationCoordinate2D(latitude: 28.6315, longitude: 77.2167)),
        AppLocation(id: UUID(), name: "Bandra West, Mumbai", shortName: "Bandra West",
                    coordinate: CLLocationCoordinate2D(latitude: 19.0596, longitude: 72.8295)),
        AppLocation(id: UUID(), name: "Koramangala, Bengaluru", shortName: "Koramangala",
                    coordinate: CLLocationCoordinate2D(latitude: 12.9352, longitude: 77.6245)),
        AppLocation(id: UUID(), name: "Salt Lake, Kolkata", shortName: "Salt Lake",
                    coordinate: CLLocationCoordinate2D(latitude: 22.5726, longitude: 88.4322)),
        AppLocation(id: UUID(), name: "T. Nagar, Chennai", shortName: "T. Nagar",
                    coordinate: CLLocationCoordinate2D(latitude: 13.0418, longitude: 80.2341)),
    ]
}

final class LocationStore: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var selected: AppLocation = AppLocation.presets[0]
    @Published var liveCoordinate: CLLocationCoordinate2D?
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var isResolvingLive = false

    private let manager = CLLocationManager()
    private var onLiveResolved: ((AppLocation) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authStatus = manager.authorizationStatus
    }

    func requestLiveLocation(completion: @escaping (AppLocation) -> Void) {
        onLiveResolved = completion
        isResolvingLive = true
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        liveCoordinate = loc.coordinate
        isResolvingLive = false

        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            guard let self else { return }
            let name = placemarks?.first.flatMap {
                [$0.subLocality, $0.locality].compactMap { $0 }.joined(separator: ", ")
            } ?? "Current Location"

            let live = AppLocation(
                id: UUID(),
                name: name.isEmpty ? "Current Location" : name,
                shortName: placemarks?.first?.subLocality ?? "Here",
                coordinate: loc.coordinate,
                isLive: true
            )
            DispatchQueue.main.async {
                self.selected = live
                self.onLiveResolved?(live)
                self.onLiveResolved = nil
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isResolvingLive = false
        onLiveResolved = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            if isResolvingLive { manager.requestLocation() }
        }
    }
}
