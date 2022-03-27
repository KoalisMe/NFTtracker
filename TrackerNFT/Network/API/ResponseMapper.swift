//
//  ResponseMapper.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation
import BoltsSwift

protocol ResponseMapperInterface {
    func map<T: Decodable>(data: Data) -> Task<T>
}

final class JSONResponseMapper: ResponseMapperInterface {
    func map<T: Decodable>(data: Data) -> Task<T> {
        let source = TaskCompletionSource<T>()
        
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            source.set(result: model)
        } catch let error {
            debugPrint("JSONDecoder fail: \(error)")
            source.set(error: GenericError.unknown )
        }
        
        return source.task
    }
}

enum GenericError: Error {
    case unknown
}
