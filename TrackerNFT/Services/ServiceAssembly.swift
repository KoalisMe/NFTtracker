//
//  ServiceAssembly.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation

final class ServiceAssembly {
    private static let shared = ServiceAssembly()
}

extension ServiceAssembly {
    static var collectionService: CollectionServiceInterface {
        CollectionService(executor: NetworkAssembly.jsonHTTPRequestExecutor)
    }
    
}
