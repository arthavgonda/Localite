//
//  Journeypersistencestore.swift
//  localite2
//
//  Created by ANOOP on 20/07/26.
//

import Foundation

actor JourneyPersistenceStore {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileName: String = "active_journey.json") {
        let baseDirectory = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory

        if !FileManager.default.fileExists(atPath: baseDirectory.path) {
            try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        }

        self.fileURL = baseDirectory.appendingPathComponent(fileName)
    }

    func load() -> ActiveJourney? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? decoder.decode(ActiveJourney.self, from: data)
    }

    func save(_ journey: ActiveJourney) {
        guard let data = try? encoder.encode(journey) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
