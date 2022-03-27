//
//  CollectionStatsHTTPRequest.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation

struct CollectionStatsHTTPRequest {
    let collectionName: String
}

extension CollectionStatsHTTPRequest: HTTPRequest {
    var method: HTTPRequestType { .GET }
    var baseUrl: String { "" }
    var pathPattern: HTTPPathPattern { .collectionStats }
    var pathVariables: HTTPURLVariables? {
        ["collection_slug": collectionName]
    }
    var queryVariables: HTTPURLVariables? { nil }
    var headers: HTTPHeaders? { Network.jsonRequestHeaders }
    var bodyPayload: HTTPBody? { nil }
    var cachePolicy: NSURLRequest.CachePolicy { .useProtocolCachePolicy }
}
