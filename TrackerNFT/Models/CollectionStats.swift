//
//  CollectionStats.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation

struct CollectionStats: Codable {
    let count: Int
    let ownersNumber: Int
    let floorPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case count
        case ownersNumber = "num_owners"
        case floorPrice = "floor_price"
    }
}
