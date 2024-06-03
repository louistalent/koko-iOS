////  EnergyStoreViewController.swift
//  kokonats
//
//  Created by sean on 2021/10/15.
//  
//

import Foundation
import UIKit
import StoreKit

class StoreViewController: UIViewController {
    private var scrollView = UIScrollView()
    private var gameListDataSource = StoreGameListCollectionViewDataSource()
    private var itemListDataSource = StoreItemListCollectionViewDataSource()
    var gameList = [GameDetail]()

    private var gameListCollectionView: UICollectionView!
    private var itemListCollectionView: UICollectionView!
    private var comingSoonLabel: UILabel!
    private var kokoCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGameList()
        configureLayout()
        gameListDataSource.storeVC = self
        itemListDataSource.eventHandler = self
        refreshConsumedItems()
        refreshKoko()
    }

    private func configureLayout() {
        let (scrollView, containerView) = scrollableView()
        self.scrollView = scrollView

        containerView.isUserInteractionEnabled = true
        let title = UILabel.formatedLabel(size: 34, text: "shop_title".localized, type: .bold)
        title.textAlignment = .left
        containerView.addSubview(title)
        title.activeConstraints(directions: [.top(.top, 88), .leading(.leading, 24), .trailing()])
        title.activeSelfConstrains([.height(44)])

        let upStackView = engergyStackView(lineNumber: 1)
        containerView.addSubview(upStackView)
        upStackView.activeConstraints(to: title, directions: [.top(.bottom, 43)])
        upStackView.activeConstraints(directions: [.centerX, .leading(.leading, 59)])

        let downStackView = engergyStackView(lineNumber: 2)
        containerView.addSubview(downStackView)
        downStackView.activeConstraints(to: upStackView, directions: [.top(.bottom, 80)])
        downStackView.activeConstraints(directions: [.centerX, .leading(.leading, 59)])

        let itemTitle = UILabel.formatedLabel(size: 34, text: "shop_item_title".localized, type: .bold, textAlignment: .left)

        containerView.addSubview(itemTitle)
        itemTitle.activeConstraints(directions: [.leading(.leading, 24), .trailing(.trailing, -24)])
        itemTitle.activeConstraints(to: downStackView, directions: [.top(.bottom, 50)])
        itemTitle.activeSelfConstrains([.height(40)])

        let gameListLayout = UICollectionViewFlowLayout()
        gameListLayout.scrollDirection = .horizontal
        gameListLayout.itemSize = CGSize(width: 80, height: 80)
        gameListLayout.minimumLineSpacing = 14
        gameListLayout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        gameListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gameListLayout)
        containerView.addSubview(gameListCollectionView)
        gameListCollectionView.activeConstraints(to: itemTitle, directions: [.leading(), .top(.bottom, 30)])
        
        gameListCollectionView.backgroundColor = .kokoBgColor
        gameListCollectionView.delegate = gameListDataSource
        gameListCollectionView.dataSource = gameListDataSource
        gameListCollectionView.register(StoreGameListCollectionViewCell.self, forCellWithReuseIdentifier: "StoreGameListCollectionViewCell")
        gameListCollectionView.showsVerticalScrollIndicator = false
        gameListCollectionView.showsHorizontalScrollIndicator = false

        containerView.addSubview(gameListCollectionView)
        gameListCollectionView.activeConstraints(directions: [.leading(), .centerX])
        gameListCollectionView.activeConstraints(to: itemTitle, directions: [.top(.bottom, 30)])
        gameListCollectionView.activeSelfConstrains([.height(80)])

        let itemListCVLayout = UICollectionViewFlowLayout()
        itemListCVLayout.scrollDirection = .vertical
        itemListCVLayout.itemSize = CGSize(width: 80, height: 170)
        itemListCVLayout.minimumLineSpacing = 14
        itemListCVLayout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)

        itemListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: itemListCVLayout)
        containerView.addSubview(itemListCollectionView)
        itemListCollectionView.register(StoreItemListCollectionViewCell.self, forCellWithReuseIdentifier: "StoreItemListCollectionViewCell")
        itemListCollectionView.delegate = itemListDataSource
        itemListCollectionView.dataSource = itemListDataSource
        itemListCollectionView.activeConstraints(to: gameListCollectionView, directions: [.top(.bottom, 20)])
        itemListCollectionView.activeConstraints(directions: [.bottom(), .leading(.leading, 24), .centerX])
        itemListCollectionView.backgroundColor = .lightBgColor
        itemListCollectionView.activeSelfConstrains([.height(360)])
        itemListCollectionView.layer.cornerRadius = 20

        comingSoonLabel = UILabel.formatedLabel(size: 14, text: "COMING SOON", type: .black, textAlignment: .center)
        containerView.addSubview(comingSoonLabel)
        comingSoonLabel.activeConstraints(to: itemListCollectionView, directions: [.leading(), .trailing(), .top(.top, 15)])
        comingSoonLabel.activeSelfConstrains([.height(22)])
        comingSoonLabel.isHidden = true
    }


    private func engergyStackView(lineNumber: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 40
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
        stackView.activeSelfConstrains([.height(120), .width(260)])
        return stackView
    }

    private func createEnergyView(for type: KokoProductType) -> UIView {
        let energyContainerView = UIView()
        energyContainerView.activeSelfConstrains([.height(120), .width(60)])

        let imageView = UIImageView(image: UIImage(named: "inapp_purchase_icon"))
        energyContainerView.addSubview(imageView)
        imageView.activeConstraints(directions: [.leading(), .trailing(), .top()])
        imageView.activeSelfConstrains([.height(60)])

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
        ApiManager.shared.getGamesList(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let gameList):
                    self.gameList = gameList
                    self.gameListDataSource.gameList = gameList
                    self.gameListCollectionView.reloadData()
                    gameList.first.flatMap {
                        self.selectGame(gameId: $0.id)
                    }
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }

    private func refreshKoko() {
        ApiManager.shared.getKokoBalance(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self?.kokoCount = Int(data.confirmed) ?? 0
                }
            }
        }
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
        comingSoonLabel.isHidden = !(itemList.count == 0)
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

extension StoreViewController: PurchaseManagerDelegate {
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

extension UIViewController {
    func scrollableView() -> (UIScrollView, UIView) {
        let scrollView = UIScrollView()
        let containerView = UIView()

        view.addSubview(scrollView)
        scrollView.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.top(), .leading(), .bottom(), .trailing()])
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addSubview(containerView)
        containerView.activeConstraints(to: scrollView.contentLayoutGuide,  anchorDirections: [.top(), .leading(), .bottom(), .trailing()])
        containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true

        return (scrollView, containerView)
    }
}

protocol StoreEventHandler {
    func handleEvent(_ event: StoreClickEvent)
}

enum StoreClickEvent {
    case purchaseGameItem(gameItem: GameItem)
}


extension StoreViewController: StoreEventHandler {
    func handleEvent(_ event: StoreClickEvent) {
        switch event {
        case .purchaseGameItem(let gameItem):
            guard (gameItem.kokoPrice ?? 0) < kokoCount else {
                self.itemListDataSource.blockPurchasing = false
                presentInsufficientKokoAlert()
                return
            }

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
