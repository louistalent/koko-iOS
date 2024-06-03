//
//  GameItemViewController.swift
//  kokonats
//
//  Created by Mac on 4/14/22.
//

import UIKit

class GameItemViewController: UIViewController {
    
    private var scrollView = UIScrollView()
    
    var gameList = [GameDetail]()
    private var gameListDataSource = StoreGameListCollectionViewDataSource()
    private var itemListDataSource = StoreItemListCollectionViewDataSource()
    
    private var itemListCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchGameList()
        configureLayout()
        //gameListDataSource.storeVC = self
        //itemListDataSource.eventHandler = self
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
        
  
        let itemTitle = UILabel.formatedLabel(size: 34, text: "shop_item_title".localized, type: .bold, textAlignment: .left)

        containerView.addSubview(itemTitle)
        itemTitle.activeConstraints(directions: [.leading(.leading, 104), .trailing(.trailing, -24)])
        itemTitle.activeConstraints(directions: [.top(.top, 20), .leading(.leading, 104), .trailing()])
        itemTitle.activeSelfConstrains([.height(40)])

        
        let kokoBg = UIView()
        kokoBg.cornerRadius = 20
        kokoBg.backgroundColor = .dollarYellow
        containerView.addSubview(kokoBg)
        kokoBg.activeSelfConstrains([.height(60)])
        kokoBg.activeConstraints(to: containerView, directions: [.leading(.leading, 60), .centerX])
        kokoBg.activeConstraints(to: itemTitle, directions: [.top(.bottom, 24)])

        let iconContainer = UIView()
        iconContainer.backgroundColor = .clear
        containerView.addSubview(iconContainer)
        iconContainer.activeConstraints(to: kokoBg, directions: [.top(), .bottom(), .leading(.leading, 30)])

        let kokoIcon = UIImageView(image: UIImage(named: "dollar_icon"))
        containerView.addSubview(kokoIcon)
        kokoIcon.activeConstraints(to: iconContainer, directions: [.leading(), .centerY])
        kokoIcon.activeSelfConstrains([.height(40), .width(40)])

        let kokoBalanceLabel = UILabel.formatedLabel(size: 28, text: "0", type: .bold, textAlignment: .left)
        containerView.addSubview(kokoBalanceLabel)
        kokoBalanceLabel.activeConstraints(to: iconContainer, directions: [.trailing(.trailing, 1), .top(), .bottom()])
        kokoBalanceLabel.activeConstraints(to: kokoIcon, directions: [.leading(.trailing, 25)])
        
        
        let gameView = UIView()
        gameView.layer.cornerRadius = 10
        gameView.backgroundColor = .lightBgColor
        containerView.addSubview(gameView)
        gameView.activeConstraints(to: kokoBg, directions: [ .top(.bottom, 40)])
        gameView.activeConstraints(to: containerView, directions: [.leading(.leading, 24), .trailing(.trailing, -24)])
        gameView.activeSelfConstrains([.height(80)])
        gameView.dropShadow(cornerRadius: 5)

        let iconImage = UIImageView()
        iconImage.backgroundColor = .clear
        gameView.addSubview(iconImage)
        iconImage.activeConstraints(to: gameView, directions: [.leading(.leading, 10), .centerY])
        iconImage.contentMode = .scaleAspectFit
        iconImage.activeSelfConstrains([.width(60), .height(60)])
        
        iconImage.image = UIImage(named: "game_thumbnail_sample")

        let titleLabel = UILabel.formatedLabel(size: 18, text: "Game Title",type:.medium, textAlignment: .left)
        titleLabel.textColor = .white
        gameView.addSubview(titleLabel)
        titleLabel.activeConstraints(to: iconImage, directions: [.leading(.trailing, 20), .centerY])



        let itemListCVLayout = UICollectionViewFlowLayout()
        itemListCVLayout.scrollDirection = .vertical
        itemListCVLayout.itemSize = CGSize(width: (screenSize.width - 80)/3.0, height: 190)
        itemListCVLayout.minimumLineSpacing = 10

        itemListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: itemListCVLayout)
        containerView.addSubview(itemListCollectionView)
        itemListCollectionView.register(StoreItemListCollectionViewCell.self, forCellWithReuseIdentifier: "StoreItemListCollectionViewCell")
        itemListCollectionView.delegate = itemListDataSource
        itemListCollectionView.dataSource = itemListDataSource
        itemListCollectionView.activeConstraints(to: gameView, directions: [.top(.bottom, 20)])
        itemListCollectionView.activeConstraints(directions: [.bottom(), .leading(.leading, 24), .centerX])
        itemListCollectionView.backgroundColor = .clear
        itemListCollectionView.activeSelfConstrains([.height(screenSize.height - 320)])
        

        
    }
    
    private func fetchGameList() {
        ApiManager.shared.getGamesList(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let gameList):
                    self.gameList = gameList
                    self.gameListDataSource.gameList = gameList
                    //self.gameListCollectionView.reloadData()
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
//        comingSoonLabel.isHidden = !(itemList.count == 0)
    }

    
    @objc func goBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
