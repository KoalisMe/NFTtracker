//
//  BackendRequestExecutor.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation
import BoltsSwift

typealias URLResponseResult<T> = (response: URLResponse, object: T)

protocol BackendRequestExecutorInterface {
    func execute<T: Decodable>(request: HTTPRequest) -> Task<T>
}

protocol JSONRequestExecutorInterface: BackendRequestExecutorInterface {
    func execute(request: HTTPRequest) -> Task<URLResponse>
    func execute<T: Decodable>(request: HTTPRequest) -> Task<URLResponseResult<T>>
}

final class BackendRequestExecutor {
    private let executor: URLRequestExecutorInterface
    private let builder: URLRequestBuilderInterface
    private let mapper: ResponseMapperInterface
    private let errorHandler: URLResponseErrorHandlerInterface
    
    init(
        executor: URLRequestExecutorInterface,
        builder: URLRequestBuilderInterface,
        mapper: ResponseMapperInterface,
        errorHandler: URLResponseErrorHandlerInterface
    ) {
        self.executor = executor
        self.builder = builder
        self.mapper = mapper
        self.errorHandler = errorHandler
    }
}

// MARK: - JSONRequestExecutorInterface

extension BackendRequestExecutor: JSONRequestExecutorInterface {
    func execute(request: HTTPRequest) -> Task<URLResponse> {
        let source = TaskCompletionSource<URLResponse>()
        
        builder
            .build(request: request)
            .continueOnSuccessWithTask { [self] urlRequest in
                executor.execute(request: urlRequest)
            }
            .continueOnSuccessWithTask { [self] payload in
                errorHandler.check(payload: payload)
            }
            .continueOnSuccessWith { urlResponse in
                source.set(result: urlResponse)
            }
            .continueOnErrorWith { error in
                source.set(error: error)
        }
        
        return source.task
    }
    
    func execute<T: Decodable>(request: HTTPRequest) -> Task<T> {
        let source = TaskCompletionSource<T>()
        
        builder
            .build(request: request)
            .continueOnSuccessWithTask { [self] urlRequest in
                executor.execute(request: urlRequest)
            }
            .continueOnSuccessWithTask { [self] payload in
                errorHandler.check(payload: payload)
            }
            .continueOnSuccessWithTask { [self] data in
                mapper.map(data: data)
            }
            .continueOnSuccessWith { model in
                source.set(result: model)
            }
            .continueOnErrorWith { error in
                source.set(error: error)
        }
        
        return source.task
    }
    
    func execute<T: Decodable>(request: HTTPRequest) -> Task<URLResponseResult<T>> {
        let source = TaskCompletionSource<URLResponseResult<T>>()
        var urlResponse: URLResponse!
        
        builder
            .build(request: request)
            .continueOnSuccessWithTask { [self] urlRequest in
                executor.execute(request: urlRequest)
            }
            .continueOnSuccessWithTask { [self] payload in
                urlResponse = payload.response
                return errorHandler.check(payload: payload)
            }
            .continueOnSuccessWithTask { [self] data -> Task<T> in
                mapper.map(data: data)
            }
            .continueOnSuccessWith { model in
                let result = URLResponseResult<T>(response: urlResponse, object: model)
                source.set(result: result)
            }
            .continueOnErrorWith { error in
                source.set(error: error)
        }
        
        return source.task
    }
}
