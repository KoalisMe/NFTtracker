//
//  HTTPPathPattern.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import Foundation

enum HTTPPathPattern: String {
    case assetListings   = "asset/{asset_contract_address}/{token_id}/listings"
    case assetOffers     = "asset/{asset_contract_address}/{token_id}/offers"
    case collectionStats = "collection/{collection_slug}/stats"
}
