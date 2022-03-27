//
//  URLRequestExecutor.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation
import BoltsSwift

typealias URLResponsePayload = (response: URLResponse?, data: Data?)

protocol URLRequestExecutorInterface {
    func execute(request: URLRequest) -> Task<URLResponsePayload>
}

final class URLRequestExecutor: URLRequestExecutorInterface {
    func execute(request: URLRequest) -> Task<URLResponsePayload> {
        let source = TaskCompletionSource<URLResponsePayload>()
        
        let urlSession = URLSession(configuration: .default)
        
        urlSession
            .dataTask(with: request) { (data, response, error) in
                urlSession.finishTasksAndInvalidate()
                
                if let error = error {
                    source.set(error: error)
                } else {
                    let payload: URLResponsePayload = (response: response, data: data)
                    source.set(result: payload)
                }
            }
            .resume()
        
        return source.task
    }
}
