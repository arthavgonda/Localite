//
//  Pnr.swift
//  localite2
//
//  Created by ANOOP on 20/07/26.
//

import Foundation

enum PNRError: LocalizedError, Equatable {
    case invalidFormat
    case notFound
    case network

    var errorDescription: String? {
        switch self {
        case .invalidFormat: return "Enter a valid 10-digit PNR."
        case .notFound: return "We couldn't find that PNR. Check the number and try again."
        case .network: return "Something went wrong. Please try again."
        }
    }
}

enum PNR {
    static func validate(_ raw: String) -> String? {
        let digits = raw.filter(\.isNumber)
        guard digits.count == 10 else { return nil }
        return digits
    }
}
