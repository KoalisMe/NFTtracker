//
//  NetworkAssembly.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation

struct NetworkAssembly {
    static var jsonHTTPRequestExecutor: JSONRequestExecutorInterface {
        BackendRequestExecutor(
            executor: URLRequestExecutor(),
            builder: URLRequestBuilder(),
            mapper: JSONResponseMapper(),
            errorHandler: URLResponseErrorHandler(mapper: JSONResponseMapper())
        )
    }
}
