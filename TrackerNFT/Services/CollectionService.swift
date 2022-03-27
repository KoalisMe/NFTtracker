//
//  CollectionService.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation
import BoltsSwift

protocol CollectionServiceInterface {
    func fetchStats(collectionName: String) -> Task<[CollectionStats]>
}

final class CollectionService {
    private let executor: JSONRequestExecutorInterface
    
    init(executor: JSONRequestExecutorInterface) {
        self.executor = executor
    }
}

// MARK: - CollectionServiceInterface

extension CollectionService: CollectionServiceInterface {
    func fetchStats(collectionName: String) -> Task<[CollectionStats]> {
        let source = TaskCompletionSource<[CollectionStats]>()
        
        let request = CollectionStatsHTTPRequest(collectionName: collectionName)
        
        let task: Task<[CollectionStats]> = executor.execute(request: request)
        task
            .continueOnSuccessWith { participants in
                source.set(result: participants)
            }
            .continueOnErrorWith { error in
                source.set(error: error)
        }
        
        return source.task
    }
}
