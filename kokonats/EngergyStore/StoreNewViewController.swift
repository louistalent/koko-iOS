//
//  StoreNewViewController.swift
//  kokonats
//
//  Created by Mac on 4/13/22.
//
	
import UIKit

class StoreNewViewController: UITableViewController {
    
    private var cellData = [CellData]()
    private let numberOfRows = 10
    
    var energyList = [EnergyItem]()
    var gameList = [GameItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44
        tableView.showsVerticalScrollIndicator = false
        view.backgroundColor = .kokoBgColor
        tableView.separatorStyle = .none
        registerCells()
//        initializeData()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        refreshEnergy()
        
        initializeData()
    }
    
    private func registerCells() {
        tableView.register(EnergyListCell.self, forCellReuseIdentifier: "EnergyListCell")
        tableView.register(ItemsListCell.self, forCellReuseIdentifier: "ItemsListCell")
        tableView.register(LabelCell.self, forCellReuseIdentifier: "LabelCell")
        tableView.register(LogoCell.self, forCellReuseIdentifier: "LogoCell")
        tableView.register(BannerCell.self, forCellReuseIdentifier: "BannerCell")
    }
    
    private func initializeData() {
        
        energyList.removeAll()
        cellData.removeAll()
        gameList.removeAll()
        
        let energy = EnergyItem(id: 1, energyId: 1, energyItemName: "エナヅーを購ス")
        energyList.append(energy)
        
        let game = GameItem(id: 1, gameId: 1, name: "Game Title", pictureUrl: nil, kokoPrice: nil)
        gameList.append(game)
        gameList.append(game)
        gameList.append(game)
        
        
        cellData.append(LogoCellData())
        cellData.append(BannerCellData())
        cellData.append(LabelCellData())
        cellData.append(EnergyCellData(energyItem: energy))
        cellData.append(LabelCellData())
        cellData.append(ItemCellData(gameItem: game))
        
        


//        ApiManager.shared.getTournamentClasses(idToken: LocalStorageManager.idToken) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                switch result {
//                case .success(let data):
//                    self.cellData[2] = TournamentListData(tournamentList: data)
//                    AppData.shared.updateTournmentListInfo(data)
//                    self.tableView.reloadData()
//                case .failure(let error):
//                    Logger.debug("error: \(error.localizedDescription)")
//                    break
//                }
//            }
//        }
//
//        ApiManager.shared.getGamesList(idToken: LocalStorageManager.idToken) { [weak self] result in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                switch result {
//                case .success(let gameList):
//                    self.cellData[3] = GameListData(gameList: gameList)
//                    AppData.shared.updateGameListInfo(gameList)
//                    self.tableView.reloadData()
//                case .failure(let error):
//                    Logger.debug("error: \(error.localizedDescription)")
//                    break
//                }
//            }
//        }
        
        self.tableView.reloadData()
    }
    
    //MARK: - TableView
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = cellData[indexPath.section].cellHeight
        return height
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 3:
            return energyList.count
        case 5:
            return gameList.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellData[indexPath.section].identifier) {
            if let cell = cell as? LabelCell, indexPath.section == 2 {
                cell.update("energy_item_title".localized)
            } else if let cell = cell as? LabelCell, indexPath.section == 4 {
                   cell.update("shop_item_title".localized)
            } else if let cell = cell as? EnergyListCell,
                      case .energyItem(let data) = cellData[indexPath.section].type {
                //cell.eventHandler = self
                cell.updateEnergyItem(data)
            } else if let cell = cell as? ItemsListCell,
                        case .gameItem(let data) = cellData[indexPath.section].type {
                cell.updateGameItem(data)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toVC: UIViewController?
        if indexPath.section == 3 {
            toVC = EnergyViewController()
        } else if indexPath.section == 5 {
            toVC = GameItemViewController()
        } else {
            return
        }
        toVC?.modalPresentationStyle = .fullScreen
        self.present(toVC!, animated: true)
    }

}

extension StoreNewViewController {
    private func showGameDetailVC(id: Int) {
//        guard let game = gameList.first(where: { $0.id == id }) else { return }
        
//        fetchGameDetailData(for: game) { [weak self] gameData in
//            let gameVC = GameDetailViewController()
//            gameVC.gameDetailData = gameData
//            self?.present(gameVC, animated: true, completion: nil)
//        }
    }
    
    private func fetchGameDetailData(for game: GameDetail, completion: ((GameDetailData) -> ())? = nil) {
        var matches: [GameMatch] = []
        var tournaments: [TournamentClassDetail] = []
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        fetchPvpGameData(for: game.id) {matchList in
            matches = matchList
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchTournamentGameData(for: game.id) { tcs in
            tournaments = tcs
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let gameData = GameDetailData(gameData: game, tournamentList: tournaments, matchList: matches)
            completion?(gameData)
        }
    }
    
    private func fetchPvpGameData(for id: Int, completion: (([GameMatch]) -> ())? = nil) {
        ApiManager.shared.getPVPMatches(idToken: LocalStorageManager.idToken, gameId: id) { result in
            switch result {
            case .success(let matchList):
                completion?(matchList)
            case .failure(let error):
                Logger.debug(error.localizedDescription)
                completion?([])
            }
        }
    }
    
    private func fetchTournamentGameData(for id: Int, completion: (([TournamentClassDetail]) -> ())? = nil) {
        ApiManager.shared.getTournamentClasses(forGameId: id) { result in
            switch result {
            case .success(let tcs):
                completion?(tcs)
            case .failure(let error):
                Logger.debug(error.localizedDescription)
                completion?([])
            }
        }
    }
}


extension StoreNewViewController: EventHandler {
    func HandleEvent(_ event: Event) {
//        switch event {
//        case .showGameDetail(let id):
//            self.showGameDetailVC(id: id)
//        case .playTournament:
//            let playgroundVC = PlaygroundViewController()
//            playgroundVC.modalPresentationStyle = .fullScreen
//            playgroundVC.modalTransitionStyle = .crossDissolve
//            present(playgroundVC, animated: false, completion: nil)
//            return
//        case .playGame:
//            return
//        case .showTournament(let tournamentClassId):
//            guard let tournamentVC = UIStoryboard.buildVC(from: "TournamentDetail") as? TournamentDetailViewController,
//                  let tournamentDetail = tournamentList.first(where: { $0.id == tournamentClassId }) else {
//                Logger.debug("something is wrong")
//                return
//            }
//            ApiManager.shared.getPlayableTournament(tournamentId: String(tournamentClassId), idToken: LocalStorageManager.idToken) { [weak self] result in
//                let info: PlayableInfo = {
//                    switch result {
//                    case .success(let tournament): return PlayableInfo(tournamentClass: tournamentDetail, tournament: tournament)
//                    case .failure(let error):
//                        Logger.debug("showTournament w/tcid = \(tournamentClassId) is not available: \(error)")
//                        return PlayableInfo(tournamentClass: tournamentDetail)
//                    }
//                }()
//                tournamentVC.playable = info
//                self?.present(tournamentVC, animated: true, completion: nil)
//            }
//
//        default:
//            break
//        }
    }
}


class LabelCellData: CellData {
    var identifier: String { return "LabelCell" }
    var type: CellType { return .label }
    var cellHeight: CGFloat { return 50 }
}


class EnergyCellData: CellData {
    private var energyItem: EnergyItem
    var type: CellType { return .energyItem(energyItem) }
    var cellHeight: CGFloat { return 100 }
    var identifier: String { return "EnergyListCell" }
    init(energyItem: EnergyItem) {
        self.energyItem = energyItem
    }
}

class ItemCellData: CellData {
    private var gameItem: GameItem
    var type: CellType { return .gameItem(gameItem) }
    var cellHeight: CGFloat { return 100 }
    var identifier: String { return "ItemsListCell" }
    init(gameItem: GameItem) {
        self.gameItem = gameItem
    }
}
