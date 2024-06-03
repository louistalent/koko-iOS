////  StoreGameItemListCollectionViewDataSource.swift
//  kokonats
//
//  Created by sean on 2022/03/19.
//  
//

import Foundation
import UIKit

final class StoreItemListCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    var eventHandler: StoreEventHandler?
    var itemList = [GameItem]()
    var purchasedItemIdList = [Int]()
    var blockPurchasing = false

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = itemList[indexPath.row]
        let isPurchased = isPurchased(item.id)

        if !isPurchased && !blockPurchasing {
            blockPurchasing = true
            eventHandler?.handleEvent(.purchaseGameItem(gameItem: item))
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreItemListCollectionViewCell", for: indexPath) as! StoreItemListCollectionViewCell
        let item = itemList[indexPath.row]
        if let url = item.pictureUrl {
            ImageCacheManager.shared.loadImage(urlString: url) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            cell.updateIcon(with: image)
                        } else {
                            Logger.debug("failed to get image data")
                        }
                    case .failure(let error):
                        Logger.debug("\(error)")
                    }
                }
            }
        }

        Logger.debug("cell for item at  item.id: \(item.id) 555555")
        cell.update(price: item.kokoPrice ?? 0, isPurchased: isPurchased(item.id) )
        return cell
    }

    private func isPurchased(_ gameItemId: Int) -> Bool {
        return purchasedItemIdList.contains(gameItemId)
    }
}
