//
//  Constants.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation

enum NFTCollection: String {
    case cryptoongoonz
    case pjpp
}

// MARK: - Network

struct Network {
    static let baseURL = "https://api.opensea.io/api/v1/"
    static let token: String? = nil
    
    static let jsonRequestHeaders: HTTPHeaders = ["Accept": "application/json"]
}

enum NetworkError: Error {
    case invalidResponse
    case failResponseCode
    case invalidBody
}
