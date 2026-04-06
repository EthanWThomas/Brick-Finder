//
//  RebrickableAPi.swift
//  Brick Finder
//
//  Created by Ethan Thomas on 8/3/25.
//

import Foundation

struct RebrickableApi {
    static var apiKey = "428202502f439447097e345473057945"
}

struct BrickableAPI {
    static var apiKey = "3-cg4C-AeNS-cbqn7"
}


enum RequestError: Error {
    case failedToCreateURL
}

enum ResponseError: LocalizedError {
    case unownedErrorOccurred
    case httpStatus(code: Int)
    
    var errorDescription: String? {
        switch self {
        case .unownedErrorOccurred:
            return "The server returned an unexpected response."
        case .httpStatus(let code):
            return "HTTP error \(code). The instructions service may be unavailable."
        }
    }
}

/// Brickset returns HTTP 200 with `{"status":"error","message":"..."}` when the request fails (e.g. invalid API key).
enum BricksetInstructionsAPIError: LocalizedError {
    case bricksetMessage(String)
    
    var errorDescription: String? {
        switch self {
        case .bricksetMessage(let message):
            return message
        }
    }
}

struct ErrorResponse: Error, Decodable {
    let detail: String
}
