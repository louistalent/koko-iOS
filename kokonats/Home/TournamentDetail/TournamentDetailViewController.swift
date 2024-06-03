//
//  TournamentDetailViewController.swift
//  kokonats
//
//  Created by yifei.zhou on 2021/09/23.
//

import UIKit

struct PlayableInfo {
    let tournamentClass: TournamentClassDetail
    var gameDetail: GameDetail?
    var tournament: PlayableTournamentDetail?
    
    init(tournamentClass: TournamentClassDetail, gameDetail: GameDetail? = nil, tournament: PlayableTournamentDetail? = nil) {
        self.tournamentClass = tournamentClass
        self.gameDetail = gameDetail
        self.tournament = tournament
    }
}

class TournamentDetailViewController: UIViewController {

    @IBOutlet weak var rulesTableView: FixedSizeTableView!
    @IBOutlet weak var rankingTableView: FixedSizeTableView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailURLLabel: UILabel!
    @IBOutlet weak var enterTournamentLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var tournamentCoverImage: UIImageView!
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var tournamentIntroLabel: UILabel!
    @IBOutlet weak var sponsorLabel: UIImageView!
    @IBOutlet weak var captureBtn: UIButton!
    

    private var buttonBackgroundView: UIView!

    private var minutes : Int = 0
    private var seconds : Int = 0
    private var index = 0
    private var timer = Timer()
    
    private var _resultView: ResultView?
    private var playingTournamentId: String?
    private var joinedAlready: Bool = false {
        didSet { self.updateButtonState() }
    }

    var playable: PlayableInfo!
    var rulesDelegate = TournamentDetailRulesDelegate()
    var rankingDelegate = TournamentDetailRankingDelegate()
    private var rankingRules: [JSONObject]? {
        didSet {
            rulesDelegate.rankingRules = rankingRules ?? [JSONObject]()
            rankingTableView.reloadData()
        }
    }

    private var rankings = [TournamentPlay]() {
        didSet {
            rankingDelegate.currentRankings = rankings
            rankingTableView.reloadData()
            if let user = AppData.shared.currentUser {
                joinedAlready = rankings.first(where: { $0.id == user.id }) != nil
            }
        }
    }
    
    private var tournamentStatus: TournamentStatusDetector.TournamentStatus {
        if let tournament = playable.tournament {
            return TournamentStatusDetector.detect(tournament: tournament, tournamentClass: playable.tournamentClass, joinedAlready: joinedAlready)
        } else {
            return TournamentStatusDetector.detectRejectReason(tournamentClass: playable.tournamentClass)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        rankingLabel.isHidden = true
        rankingLabel.font = UIFont.getKokoFont(type: .bold, size: 14)
        rankingLabel.text = "tnmvc_ranking_label_title".localized
        rankingLabel.textColor = .lightWhiteFontColor

        ruleLabel.font = UIFont.getKokoFont(type: .bold, size: 14)
        ruleLabel.text = "tnmvc_rules_label_title".localized
        ruleLabel.textColor = .lightWhiteFontColor

        tournamentIntroLabel.font = UIFont.getKokoFont(type: .medium, size: 14)
        tournamentIntroLabel.textColor = .white
        tournamentIntroLabel.textAlignment = .left
        tournamentIntroLabel.numberOfLines = 0
        playable.tournamentClass.description.flatMap {
            tournamentIntroLabel.text = $0
         */
        

        view.backgroundColor = .kokoBgColor

        rulesTableView.dataSource = rulesDelegate
        rulesTableView.delegate = rulesDelegate
        rulesTableView.showsVerticalScrollIndicator = false
        rankingTableView.dataSource = rankingDelegate
        rankingTableView.delegate = rankingDelegate
        rankingTableView.showsVerticalScrollIndicator = false
        rulesTableView.separatorStyle = .none
        rankingTableView.separatorStyle = .none

        tournamentCoverImage.backgroundColor = .kokoBgColor
        tournamentCoverImage.clipsToBounds = true
        tournamentCoverImage.layer.cornerRadius = 10

        buttonBackgroundView = UIView()
        view.insertSubview(buttonBackgroundView, at: 0)
        buttonBackgroundView.activeConstraints(to: enterTournamentLabel)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: screenSize.width - 48, height: 48)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor.bannerBlue.cgColor, UIColor.bannerPurple.cgColor]
        buttonBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        buttonBackgroundView.clipsToBounds = true
        buttonBackgroundView.layer.cornerRadius = 10

        enterTournamentLabel.font = UIFont.getKokoFont(type: .medium, size: 14)
        enterTournamentLabel.backgroundColor = .clear
        enterTournamentLabel.clipsToBounds = true
        enterTournamentLabel.lineBreakMode = .byWordWrapping
        enterTournamentLabel.numberOfLines = 2
        enterTournamentLabel.layer.cornerRadius = 5
        enterTournamentLabel.textAlignment = .center
        enterTournamentLabel.textColor = .white

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(enterTournament(_:)))
        enterTournamentLabel.isUserInteractionEnabled = false
        enterTournamentLabel.addGestureRecognizer(tapGR)


        view.bringSubviewToFront(enterTournamentLabel)

        playable.tournamentClass.rankingPayout.flatMap {
            rankingRules = parseRankingRules($0)
        }

        updateButtonState()

        fetchPlayingId() { [weak self] in
            self?.refreshRanking()
            self?.fetchGameId()
        }
        fetchCoverImage()
        
        captureBtn.addTarget(self, action: #selector(captureTapped(_:)), for: .touchUpInside)
        let tapSponsor = UITapGestureRecognizer(target: self, action: #selector(self.sponsorTapped))
        sponsorLabel.addGestureRecognizer(tapSponsor)	
    }
    	
    @IBAction func captureTapped(_ sender: Any) {
        UIPasteboard.general.string = "http://www.cloud7.link"
       }
    @IBAction func sponsorTapped(_ sender: Any) {
        let url = URL (string: "http://www.cloud7.link")!
        UIApplication.shared.open (url)
       }

    private func fetchCoverImage() {
        if let coverImageUrl = playable.tournamentClass.coverImageUrl {
            ImageCacheManager.shared.loadImage(urlString: coverImageUrl) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            self?.tournamentCoverImage.image = image
                        } else {
                            Logger.debug("failed to get image data")
                        }
                    case .failure(let error):
                        Logger.debug("\(error)")
                        break
                    }
                }
            }
        }
    }
    
    private func fetchGameId() {
    
        ApiManager.shared.getGameInfo(gameId: String(playable.tournamentClass.gameId), idToken: LocalStorageManager.idToken) { [weak self] result in
            switch result {
            case .success(let gameData):
                self?.playable.gameDetail = gameData
            case .failure(let error):
                Logger.debug("fetchGameInfo failure: \(error)")
            }
        }
    }

    private func fetchPlayingId(completion: (() -> ())? = nil) {
        ApiManager.shared.getPlayableTournament(tournamentId: String(playable.tournamentClass.id), idToken: LocalStorageManager.idToken) { [weak self] result in
            switch result {
            case .success(let data):
                self?.playingTournamentId = String(data.id)
                self?.playable.tournament = data
                self?.updateButtonState()
            case .failure:
                self?.playable.tournament = nil
                self?.updateButtonState()
            }
            completion?()
        }
    }
    
    private func getRemainTime() -> (Int , Int ){
        let startDate = playable.tournamentClass.startTime?.kokoTimeStrToDate()
        
        let durationSecond = playable.tournamentClass.durationSecond ?? 0
        
        let endDate = (startDate?.added(second: durationSecond))!
        let current = Date()
        let diff = (startDate?.distance(to: endDate))!
        Logger.debug("\(diff)")
        let min = (Int (diff) % 3600) / 60
        let sec = Int (diff) % 60
        return ( min , sec )
    }
    
    private func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 0.5 , target: self, selector: (#selector(updateTitle)), userInfo: nil, repeats: true)
        ( minutes ,seconds ) = getRemainTime()
    }
   
    @objc func updateTitle(){
        
        if(index % 2 == 0){
            if self.seconds == 0 {
                if self.minutes == 0
                    { return }
                else {
                    self.seconds = 60
                    self.minutes -= 1
                }
            }
            self.seconds -= 1
            enterTournamentLabel.text  = "tnmvc_button_enternow_title".localized + "  \n" + "\(minutes):" + "\(seconds)"
        }
        index += 1
     

    }
    
    private func updateButtonState() {
        let status = tournamentStatus
        Logger.debug("detected status: \(status)")
        switch status {
        case .playable:
            buttonBackgroundView.isHidden = false
            enterTournamentLabel.text = "tnmvc_button_playnow_title".localized
            enterTournamentLabel.backgroundColor = nil
            enterTournamentLabel.isUserInteractionEnabled = true
            
        case .finished:
            buttonBackgroundView.isHidden = true
            enterTournamentLabel.isUserInteractionEnabled = false
            enterTournamentLabel.backgroundColor = .lightBgColor
            enterTournamentLabel.text = "tnmvc_button_finished_title".localized
            
        case .notStartedYet:
            enterTournamentLabel.isUserInteractionEnabled = false
            buttonBackgroundView.isHidden = true
            enterTournamentLabel.backgroundColor = .lightBgColor
            let startStr = playable.tournamentClass.startTime ?? "tnmvc_button_unknown".localized
            enterTournamentLabel.text = "\(startStr) 〜"
            
        case .full:
            buttonBackgroundView.isHidden = true
            enterTournamentLabel.isUserInteractionEnabled = false
            enterTournamentLabel.backgroundColor = .lightBgColor
            startTimer()
        }
    }

    private func refreshRanking() {
        guard let playingTournamentId = playingTournamentId else {
            return
        }
        // NOTE: Data retrieval method changes depending on status.
        //  ref: https://github.com/BiiiiiT-Inc/koko-iOS/issues/97
        switch tournamentStatus {
        case .playable, .full:
            fetchCurrentRanking(tournamentId: playingTournamentId) { [weak self] plays in
                self?.rankings = plays
                self?.rankingLabel.isHidden = false
            }
        case .finished:
            fetchFinishedRanking(tournamentClassId: playable.tournamentClass.id) { [weak self] plays in
                self?.rankings = plays
                self?.rankingLabel.isHidden = false
            }
        case .notStartedYet: // don't display rankings
            rankings = []
            rankingLabel.isHidden = true
        }
        
    }
    
    private func fetchCurrentRanking(tournamentId: String, completion: (([TournamentPlay]) -> Void)? = nil) {
        ApiManager.shared.getTournamentRanking(tournamentId: tournamentId, idToken: LocalStorageManager.idToken) { [weak self] result in
            switch(result) {
            case .success(let data): completion?(data)
            case .failure(let error):
                Logger.debug(error.localizedDescription)
                completion?([])
            }
        }
    }
    
    private func fetchFinishedRanking(tournamentClassId id: Int, completion: (([TournamentPlay]) -> Void)? = nil) {
        ApiManager.shared.getTournamentHistories(tounamentClassId: id) { [weak self] result in
            switch result {
            case .success(let tournaments):
                if let firstTournament = tournaments.first {
                    self?.fetchCurrentRanking(tournamentId: String(firstTournament.id), completion: completion)
                } else {
                    completion?([])
                }
            case .failure(let error):
                Logger.debug(error.localizedDescription)
                completion?([])
            }
        }
    }

    @IBAction func enterTournament(_ sender: Any) {
        guard AppData.shared.isLoggedIn() else {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .needLogin, object: nil)
            }
            return
        }
        guard let playingTournamentId = playingTournamentId else {
            return
        }
        let showError: (_ error: CommonError) -> () = { [weak self] error in
            switch error {
            case .authenticationError:
                self?.showErrorMessage(title: "error_failed_join_title".localized,
                                       reason: "error_need_to_login_first".localized)
            default:
                self?.showErrorMessage(title: "error_failed_join_title".localized,
                                       reason: "error_reason_game_not_start".localized)
            }
        }
        ApiManager.shared.joinTournament(tournamentId: playingTournamentId,
                                         idToken: LocalStorageManager.idToken) { [weak self] result in
            switch result {
            case .success(let tournamentPlay):
                guard let self = self, let game = self.playable.gameDetail else { return }
                ApiManager.shared.getGameAuth(gameId: game.id) { [weak self] result in
                    switch result {
                    case .success(let token):
                        self?.startTournament(gameAuth: token,
                                              playId: String(tournamentPlay.id),
                                              playDuration: self?.playable.tournamentClass.durationPlaySecond ?? 0)
                    case .failure(let error): showError(error)
                    }
                }
            case .failure(let error): showError(error)
            }
        }
    }
    
    private func alertEntryFee(){
        let alert = UIAlertController(title: "alert_entryfee_title".localized, message: "alert_entryfee_content" , preferredStyle: .alert)
        let back = UIAlertAction(title: "Back", style: .default, handler: { (action) -> Void in
            print("Back button tapped")
        })
        // Create Cancel button with action handlder
        let ok = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Ok button tapped")
        }
        //Add OK and Cancel button to an Alert object
        alert.addAction(back)
        alert.addAction(ok)
       
        self.present(alert, animated: true, completion: nil)
    }
 
    private func startTournament(gameAuth: String, playId: String, playDuration: Int) {
        alertEntryFee()
        let playgroundVC = PlaygroundViewController()
        playgroundVC.requestInfo = RequestInfo(gameAuth: gameAuth,
                                               playId: playId,
                                               playType: .tournament,
                                               gameUrl: playable.gameDetail?.cdnUrl ?? "",
                                               duration: playDuration)
        playgroundVC.modalPresentationStyle = .fullScreen
        playgroundVC.modalTransitionStyle = .crossDissolve
        playgroundVC.resultHandler = self
        present(playgroundVC, animated: false, completion: nil)
    }

    //"[{\"startRank\": \"1\", \"endRank\":\"2\", \"payout\":1000}, {\"startRank\": \"2\", \"endRank\":\"9\", \"payout\":300}]"
    private func parseRankingRules(_ rankingRules: String) -> [JSONObject]? {
        let data = Data(rankingRules.utf8)
        do {
            // make sure this JSON is in the format we expect
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [JSONObject] {
                let array = json.sorted(by: {
                    let first = Int($0["startRank"] as? String ?? "99") ?? 99
                    let second = Int($1["startRank"] as? String ?? "99") ?? 99
                    return first < second
                })
                return array
            }
            return nil
        } catch let error as NSError {
            Logger.debug("Failed to load: \(error.localizedDescription)")
            return nil
        }
    }
}

extension TournamentDetailViewController: GameResultHandler {
    func handleEvent(_ event: ResultEvent) {
        switch event {
        case .gameResult:
            guard let playingTournamentId = playingTournamentId else {
                return
            }

            if _resultView != nil {
                _resultView?.removeFromSuperview()
                _resultView = nil
            }

            let resultView = ResultView()
            _resultView = resultView
            resultView.resultHandler = self
            view.addSubview(resultView)
            resultView.activeConstraints()
            ApiManager.shared.getTournamentRanking(tournamentId: playingTournamentId, idToken: LocalStorageManager.idToken) { result in
                AppData.shared.getCurrentUser { userInfo in
                    guard let userInfo = userInfo else {
                        return
                    }

                    DispatchQueue.main.async {
                        switch(result) {
                        case .success(let data):
                            resultView.updateResult(type: .touranment(data), currentUserInfo: userInfo)
                        case .failure(let error):
                            Logger.debug(error.localizedDescription)
                        }
                    }
                }
            }
        case .backHome:
            self.dismiss(animated: true, completion: nil)
            _resultView = nil
        case .playAgain:
            self.enterTournament(self)
            _resultView?.removeFromSuperview()
            _resultView = nil
        }
    }
}

