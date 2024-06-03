//
//  EnergyViewController.swift
//  kokonats
//
//  Created by Mac on 4/14/22.
//

import Foundation
import UIKit
import StoreKit

class EnergyViewController: UIViewController {
    private var scrollView = UIScrollView()
    private var itemListDataSource = StoreItemListCollectionViewDataSource()
    private var itemListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // fetchGameList()
        configureLayout()
        // gameListDataSource.storeVC = self
        // itemListDataSource.eventHandler = self
        //refreshConsumedItems()
        //refreshKoko()
        
    }
    
    private func configureLayout() {
        self.view.backgroundColor = .kokoBgColor
        
        let (scrollView, containerView) = scrollableView()
        self.scrollView = scrollView
        
        containerView.isUserInteractionEnabled = true
        
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.activeConstraints(to: view, directions: [.leading(.leading, 24), .top(.top, 40)])
        backButton.activeSelfConstrains([.height(50), .width(50)])
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        
        let title = UILabel.formatedLabel(size: 34, text: "energy_item_title".localized, type: .bold)
        title.textAlignment = .left
        containerView.addSubview(title)
        title.activeConstraints(directions: [.top(.top, 20), .leading(.leading, 104), .trailing()])
        title.activeSelfConstrains([.height(40)])
        
        let energyBg = UIView()
        energyBg.cornerRadius = 20
        energyBg.backgroundColor = .lightBgColor
        containerView.addSubview(energyBg)
        energyBg.activeSelfConstrains([.height(60)])
        energyBg.activeConstraints(to: containerView, directions: [.leading(.leading, 60), .centerX])
        energyBg.activeConstraints(to: title, directions: [.top(.bottom, 24)])
        let energyIcon = UIImageView(image: UIImage(named: "energy_icon"))
        containerView.addSubview(energyIcon)
        energyIcon.activeConstraints(to: energyBg, directions: [.leading(.leading, 20), .centerY])
        energyIcon.activeSelfConstrains([.height(30), .width(16)])
        
        let energyScoreLabel = UILabel.formatedLabel(size: 24, type: .black, textAlignment: .center)
        containerView.addSubview(energyScoreLabel)
        energyScoreLabel.activeConstraints(to: energyBg, directions: [.leading(.leading, 39), .centerY, .trailing(.trailing, 1), .top(), .bottom()])
        energyScoreLabel.text = "123,456,789"

        let upStackView = engergyStackView(lineNumber: 1)
        containerView.addSubview(upStackView)
        upStackView.activeConstraints(to: energyBg, directions: [.top(.bottom, 20)])
        upStackView.activeConstraints(directions: [.centerX, .leading(.leading, 10)])

        let downStackView = engergyStackView(lineNumber: 2)
        containerView.addSubview(downStackView)
        downStackView.activeConstraints(to: upStackView, directions: [.top(.bottom, 20)])
        downStackView.activeConstraints(directions: [.centerX, .leading(.leading, 10)])
    }
    
    @objc func goBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
 
    private func engergyStackView(lineNumber: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .equalSpacing

        if lineNumber == 1 {
            let imageView1 = createEnergyView(for: .energy85)
            let imageView2 = createEnergyView(for: .energy180)
            let imageView3 = createEnergyView(for: .energy430)
            stackView.addArrangedSubview(imageView1)
            stackView.addArrangedSubview(imageView2)
            stackView.addArrangedSubview(imageView3)
        } else if lineNumber == 2 {
            let imageView1 = createEnergyView(for: .energy855)
            let imageView2 = createEnergyView(for: .energy1720)
            let imageView3 = createEnergyView(for: .energy4300)
            stackView.addArrangedSubview(imageView1)
            stackView.addArrangedSubview(imageView2)
            stackView.addArrangedSubview(imageView3)
        }
        stackView.activeSelfConstrains([.height(160), .width(260)])
        return stackView
    }
    
    
    private func createEnergyView(for type: KokoProductType) -> UIView {
        let energyContainerView = UIView()
        energyContainerView.activeSelfConstrains([.height(160), .width((screenSize.width - 50)/3.0)])
        energyContainerView.backgroundColor = .lightBgColor
        energyContainerView.layer.cornerRadius = 10
        energyContainerView.dropShadow(cornerRadius: 5)
        
        let imageView = UIImageView(image: UIImage(named: "inapp_purchase_icon"))
        energyContainerView.addSubview(imageView)
        imageView.activeConstraints(directions: [.top(.top, 20), .centerX])
        imageView.activeSelfConstrains([.width(60), .height(60)])

        let energyLabel = UILabel.formatedLabel(size: 14, text: "X \(type.energy)", textAlignment: .center)
        energyContainerView.addSubview(energyLabel)
        energyLabel.activeConstraints(to: imageView, directions: [.top(.bottom, 8), .centerX])

        energyLabel.activeSelfConstrains([.height(18), .width(60)])

        let priceLabel = UILabel.formatedLabel(size: 20, text: "¥ \(type.price)", textAlignment: .center)
        energyContainerView.addSubview(priceLabel)
        priceLabel.activeConstraints(to: energyLabel, directions: [.centerX, .top(.bottom, 6)])
        priceLabel.activeSelfConstrains([.height(28), .width(60)])

        let tapAction = EnergyTapGesture(target: self, action: #selector(purchaseEngergyAction(sender:)))
        tapAction.type = type
        energyContainerView.addGestureRecognizer(tapAction)
        energyContainerView.isUserInteractionEnabled = true
        energyContainerView.isUserInteractionEnabled = true
        return energyContainerView
    }
    
    @objc private func purchaseEngergyAction(sender: Any) {
        guard AppData.shared.isLoggedIn() else {
            NotificationCenter.default.post(name: .needLogin, object: nil)
            return
        }
        if let energyTapAction = sender as? EnergyTapGesture,
           let type = energyTapAction.type {
            guard let product = StoreManager.shared.product(identifier: type.identifier) else {
                handleFailure(title: "購入が失敗しました", reason: "まだ対応中ですので、購入ができません。") { _ in
                }
                return
            }
            PurchaseManager.shared.delegate = self
            PurchaseManager.shared.buy(product)
        }
    }
    
    private func handleFailure(title: String, reason: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: reason , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            completion(true)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func fetchGameList() {
//        ApiManager.shared.getGamesList(idToken: LocalStorageManager.idToken) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                switch result {
//                case .success(let gameList):
//                    self.gameList = gameList
//                    self.gameListDataSource.gameList = gameList
//                    self.gameListCollectionView.reloadData()
//                    gameList.first.flatMap {
//                        self.selectGame(gameId: $0.id)
//                    }
//                case .failure(let error):
//                    Logger.debug("error: \(error.localizedDescription)")
//                    break
//                }
//            }
//        }
    }

    private func refreshKoko() {
//        ApiManager.shared.getKokoBalance(idToken: LocalStorageManager.idToken) { [weak self] result in
//            DispatchQueue.main.async {
//                if case .success(let data) = result {
//                    self?.kokoCount = Int(data.confirmed) ?? 0
//                }
//            }
//        }
    }


    private func refreshConsumedItems() {
        ApiManager.shared.getPurchasedGameItems(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let purchasedItemList):
                    let gameItemIdList = purchasedItemList.compactMap { $0.gameItemId }
                    self.updatePurchasedItemList(gameItemIdList)
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }

    private func updatePurchasedItemList(_ list: [Int]) {
        itemListDataSource.purchasedItemIdList = list
        itemListCollectionView.reloadData()
        itemListDataSource.blockPurchasing = false
    }

    func selectGame(gameId: Int) {
        ApiManager.shared.getGameItems(idToken: LocalStorageManager.idToken, gameId: String(gameId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let itemList):
                    self?.updateItemList(itemList)
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }

    private func updateItemList(_ itemList: [GameItem]) {
        itemListDataSource.itemList = itemList
        itemListCollectionView.reloadData()
        // comingSoonLabel.isHidden = !(itemList.count == 0)
    }

    private func purchaseItem(gameItemId: Int) {
        ApiManager.shared.exchangeGameItem(idToken: LocalStorageManager.idToken, gameItemId: gameItemId) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.refreshKoko()
                    self?.itemListDataSource.purchasedItemIdList.append(gameItemId)
                    if let list = self?.itemListDataSource.purchasedItemIdList {
                        self?.updatePurchasedItemList(list)
                    }
                default:
                    self?.itemListDataSource.blockPurchasing = false
                    break
                }

            }
        }
    }

    private func presentInsufficientKokoAlert() {
        let alert = UIAlertController(title: "shop_403_koko_error_title".localized, message: "shop_403_koko_error_description".localized , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        }))

        self.present(alert, animated: true, completion: nil)
    }

}

extension EnergyViewController: PurchaseManagerDelegate {
    func purchaseManagerDidPurchaseKoko(transaction: SKPaymentTransaction, completion: @escaping () -> Void) {
        if true {
            let alert = UIAlertController(title: "購入が成功しました。", message: "マイページで確認してください。" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            }))

            self.present(alert, animated: true, completion: nil)
        } else {

        }
    }

    func purchaseManagerFailedPurchaseKoko(transaction: SKPaymentTransaction) {
        let error: String = transaction.error?.localizedDescription ?? "failed to puchase koko"
        let alert = UIAlertController(title: "購入が失敗しました。", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

private class EnergyTapGesture: UITapGestureRecognizer {
    var type: KokoProductType?
}

extension EnergyViewController: StoreEventHandler {
    func handleEvent(_ event: StoreClickEvent) {
        switch event {
        case .purchaseGameItem(let gameItem):
//            guard (gameItem.kokoPrice ?? 0) < kokoCount else {
//                self.itemListDataSource.blockPurchasing = false
//                presentInsufficientKokoAlert()
//                return
//            }

            let alert = UIAlertController(title: "shop_purchased_confirm_label".localized, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "purchase_confirm_ok".localized, style: .default, handler: { [weak self] _ in
                self?.purchaseItem(gameItemId: gameItem.id)
            }))
            alert.addAction(UIAlertAction(title: "purchase_confirm_no".localized, style: .cancel, handler: { _ in
                self.itemListDataSource.blockPurchasing = false
            }))
            self.present(alert, animated: true, completion: nil)
//        default:
//            break
        }
    }
}
