//
//  URLResponseErrorHandler.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation
import BoltsSwift

protocol URLResponseErrorHandlerInterface {
    func check(payload: URLResponsePayload) -> Task<URLResponse>
    func check(payload: URLResponsePayload) -> Task<Data>
}

final class URLResponseErrorHandler: URLResponseErrorHandlerInterface {
    private static let HTTPSuccessCode: Int = 200
    private static let HTTPSuccessEmptyBodyCode: Int = 204
    
    private let mapper: ResponseMapperInterface
    
    init(mapper: ResponseMapperInterface) {
        self.mapper = mapper
    }
    
    func check(payload: URLResponsePayload) -> Task<URLResponse> {
        let source = TaskCompletionSource<URLResponse>()
        
        let task: Task<URLResponse> = validateResponse(payload: payload)
        task
            .continueOnSuccessWithTask { _ -> Task<URLResponse> in
                return self.checkData(into: payload)
            }
            .continueOnSuccessWith { data in
                source.set(result: data)
            }
            .continueOnErrorWith { error in
                source.set(error: error)
        }
        
        return source.task
    }
    
    func check(payload: URLResponsePayload) -> Task<Data> {
        let source = TaskCompletionSource<Data>()
        
        let task: Task<URLResponse> = validateResponse(payload: payload)
        task
            .continueOnSuccessWithTask { _ -> Task<Data> in
                return self.checkData(into: payload)
            }
            .continueOnSuccessWith { data in
                source.set(result: data)
            }
            .continueOnErrorWith { error in
                source.set(error: error)
        }
        
        return source.task
    }
}

private extension URLResponseErrorHandler {
    func validateResponse(payload: URLResponsePayload) -> Task<URLResponse> {
        let source = TaskCompletionSource<URLResponse>()
        
        // Check response
        guard let response = payload.response as? HTTPURLResponse else {
            source.set(error: NetworkError.invalidResponse)
            return source.task
        }
        
        // Check response code
        guard
            response.statusCode == URLResponseErrorHandler.HTTPSuccessCode ||
            response.statusCode == URLResponseErrorHandler.HTTPSuccessEmptyBodyCode
        else {
            source.set(error: NetworkError.failResponseCode)
            return source.task
        }
        
        source.set(result: response)
        
        return source.task
    }
    
    func checkData(into payload: URLResponsePayload) -> Task<Data> {
        let source = TaskCompletionSource<Data>()
        
        guard let data = payload.data else {
            source.set(error: NetworkError.invalidBody)
            return source.task
        }
        
        source.set(result: data)
        
        return source.task
    }
    
    func checkData(into payload: URLResponsePayload) -> Task<URLResponse> {
        let source = TaskCompletionSource<URLResponse>()

        guard
            let _ = payload.data,
            let response = payload.response
        else {
            source.set(error: NetworkError.invalidBody)
            return source.task
        }
        
        source.set(result: response)

        return source.task
    }
}
