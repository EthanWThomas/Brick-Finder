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

enum RequstError: Error {
    case failedToCreateURL
}

enum ResponseError: Error {
    case unownedErrorOccurred
}

struct ErrorResponse: Error, Decodable {
    let detail: String
}
