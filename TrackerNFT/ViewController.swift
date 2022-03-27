//
//  ViewController.swift
//  TrackerNFT
//
//  Created by Oleg Kasarin on 27.03.22.
//

import UIKit

final class ViewController: UIViewController {

    private lazy var collectionService: CollectionServiceInterface = {
        ServiceAssembly.collectionService
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionService
            .fetchStats(collectionName: NFTCollection.cryptoongoonz.rawValue)
            .continueOnSuccessWith { collectionStats in
                print(collectionStats)
            }
            .continueOnErrorWith { error in
                print(error)
        }
    }
}
