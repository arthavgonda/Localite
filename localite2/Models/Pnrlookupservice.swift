//
//  Pnrlookupservice.swift
//  localite2
//
//  Created by ANOOP on 20/07/26.
//

import Foundation

protocol PNRLookupServicing: Sendable {
    func lookup(pnr: String) async throws -> JourneyInfo
}

struct MockPNRLookupService: PNRLookupServicing {
    func lookup(pnr: String) async throws -> JourneyInfo {
        try await Task.sleep(nanoseconds: 900_000_000)
        try Task.checkCancellation()

        guard PNR.validate(pnr) != nil else {
            throw PNRError.invalidFormat
        }

        if pnr == "0000000000" {
            throw PNRError.notFound
        }

        return JourneyInfo(
            destinationStation: "Mathura",
            totalMinutes: 40,
            minutesRemaining: 22,
            stationsAlongRoute: 4,
            regionalSpecialtiesCount: 4
        )
    }
}
