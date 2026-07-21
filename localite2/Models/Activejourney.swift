//
//  Activejourney.swift
//  localite2
//
//  Created by ANOOP on 20/07/26.
//

import Foundation

struct ActiveJourney: Codable, Equatable {
    let pnr: String
    var journeyInfo: JourneyInfo
    let startedAt: Date
}
