//
//  HTTPRequest.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation

enum HTTPRequestType: String {
    case GET = "GET"
    case POST = "POST"
}

typealias HTTPBody = [String: Any]
typealias HTTPHeaders = [String: String]
typealias HTTPURLVariables = [String: String]

protocol HTTPRequest: BaseHTTPRequest {
}

// MARK: - BaseHTTPRequest

protocol BaseHTTPRequest {
    var method: HTTPRequestType { get }
    var baseUrl: String { get }
    var pathPattern: HTTPPathPattern { get }
    var pathVariables: HTTPURLVariables? { get }
    var queryVariables: HTTPURLVariables? { get }
    var headers: HTTPHeaders? { get }
    var bodyPayload: HTTPBody? { get }
    var cachePolicy: NSURLRequest.CachePolicy { get }
}
