//
//  Models.swift
//  localite
//
//  Created by ANOOP on 19/07/26.
//

import Foundation
import CoreLocation

struct Journey: Codable, Identifiable {
    var id: String { pnr }
    let pnr: String
    let trainName: String
    let trainNumber: String
    let stations: [Station]
}

struct Station: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let code: String
    let arrivalTime: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
