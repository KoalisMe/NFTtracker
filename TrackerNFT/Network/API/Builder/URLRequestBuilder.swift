//
//  URLRequestBuilder.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation
import BoltsSwift

protocol URLRequestBuilderInterface {
    func build(request: HTTPRequest) -> Task<URLRequest>
}

final class URLRequestBuilder: URLRequestBuilderInterface {
    enum URLRequestBuilderError: Error {
        case invalidBaseURL
        case invalidURLParameters
        case invalidBodyPayload
    }
    
    func build(request: HTTPRequest) -> Task<URLRequest> {
        let source = TaskCompletionSource<URLRequest>()
        
        buildURL(request: request)
            .continueOnSuccessWithTask { url -> Task<URLRequest> in
                return self.buildURLRequest(url: url, request: request)
            }
            .continueOnSuccessWith { urlRequest in
                source.set(result: urlRequest)
            }
            .continueOnErrorWith { error in
                source.set(error: error)
        }
        
        return source.task
    }
}

// MARK: - Private API

private extension URLRequestBuilder {
    
    // MARK: - Build URL stuff
    
    func buildURL(request: HTTPRequest) -> Task<URL> {
        let source = TaskCompletionSource<URL>()
        
        let baseURLString: String = Network.baseURL
        
        guard let baseURL = URL(string: baseURLString) else {
            source.set(error: URLRequestBuilderError.invalidBaseURL)
            return source.task
        }
        
        do {
            let url = try buildURL(baseURL: baseURL, request: request)
            source.set(result: url)
        } catch let error {
            source.set(error: error)
        }
        
        return source.task
    }
    
    func buildURL(baseURL: URL, request: HTTPRequest) throws -> URL {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw URLRequestBuilderError.invalidBaseURL
        }
        
        if let path = buildPath(request: request) {
            components.path += path
        }
        
        if let queryItems = buildQueryItems(request: request) {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw URLRequestBuilderError.invalidURLParameters
        }
        
        return url
    }
    
    func buildPath(request: HTTPRequest) -> String? {
        guard let variables = request.pathVariables else {
            return request.pathPattern.rawValue
        }
        
        var path = request.pathPattern.rawValue
        for (key, value) in variables {
            path = path.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        return path
    }
    
    func buildQueryItems(request: HTTPRequest) -> [URLQueryItem]? {
        guard let variables = request.queryVariables else {
            return nil
        }
        
        var queryItems: [URLQueryItem] = []
        for (key, value) in variables {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        return queryItems
    }
    
    // MARK: - Build URLRequest stuff
    
    func buildURLRequest(url: URL, request: HTTPRequest) -> Task<URLRequest> {
        let source = TaskCompletionSource<URLRequest>()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        do {
            let body = try buildBody(request: request)
            urlRequest.httpBody = body
        } catch let error {
            source.set(error: error)
        }
        
        urlRequest = addHeaders(from: request, to: urlRequest)
        
        source.set(result: urlRequest)
        
        return source.task
    }
    
    func buildBody(request: HTTPRequest) throws -> Data? {
        var body: HTTPBody = [:]
        
        if let payload = request.bodyPayload {
            body = body.merging(payload, uniquingKeysWith: { (current, _) in current })
        }
        
        if body.isEmpty {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            return data
        } catch {
            throw URLRequestBuilderError.invalidBodyPayload
        }
    }
    
    func addHeaders(from request: HTTPRequest, to urlRequest: URLRequest) -> URLRequest {
        guard let headers = request.headers else {
            return urlRequest
        }
        
        var updatedURLRequest = urlRequest
        
        if let token = Network.token {
            updatedURLRequest.setValue(token, forHTTPHeaderField: "X-API-KEY")
        }
        
        for (key, value) in headers {
            updatedURLRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return updatedURLRequest
    }
}
