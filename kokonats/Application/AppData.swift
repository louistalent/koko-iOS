////  AppData.swift
//  kokonats
//
//  Created by sean on 2021/10/11.
//  
//

import Foundation

final class AppData {
    static var shared = AppData()

    private static var appData: AppData {
        return AppData.shared
    }

    private init() {}

    var currentUser: UserInfo?

    private (set) var gameList: [GameDetail]?

    private (set) var gameTagList: [String]?

    private (set) var tournamentTagList: [String]?

    func updateGameListInfo(_ gameList: [GameDetail]) {
        self.gameList = gameList
        let gameTags = gameList.compactMap { $0.category }
        self.gameTagList = gameTags.removingDuplicates()
    }

    func updateTournmentListInfo(_ tournamentList: [TournamentClassDetail]) {
        let allTags = tournamentList.flatMap({ $0.tags })
        tournamentTagList = allTags.removingDuplicates()
    }

    func isLoggedIn() -> Bool {
        return !LocalStorageManager.idToken.isEmpty
    }

    func getCurrentUser(showSignupViewIfNeeded: Bool = true, completion: @escaping (UserInfo?) -> Void) {
        guard !LocalStorageManager.idToken.isEmpty else {
            if showSignupViewIfNeeded {
                NotificationCenter.default.post(name: .needLogin, object: nil)
            }
            completion(nil)
            return
        }

        if let userInfo = AppData.shared.currentUser {
            completion(userInfo)
        } else {
            ApiManager.shared.getUserInfo(idToken: LocalStorageManager.idToken) { result in
                switch result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    if error == .rejectedByServer, showSignupViewIfNeeded {
                        NotificationCenter.default.post(name: .needLogin, object: nil)
                    }
                    Logger.debug(error.localizedDescription)
                }
            }
        }
    }


    func logout() {
        currentUser = nil
        LocalStorageManager.remove(key: .idToken)
        NotificationCenter.default.post(name: .logout, object: nil)
    }

    private var nameList: [String] = ["night",
                              "hor",
                              "ウソトノプ",
                              "アナフマ",
                              "ウシタロ",
                              "サナデ",
                              "シトノマモ",
                              "アチヌヨ",
                              "ククテズン",
                              "山本秀也",
                              "石田洋二",
                              "コーニエル",
                              "小林正道",
                              "ソロミオン",
                              "ローマンド",
                              "タンリー",
                              "アンソニー",
                              "アントム",
                              "オリヴェイ",
                              "ルドウィン",
                              "ギデオドア",
                              "ルーファス",
                              "マルコリー",
                              "ルーパット",
                              "セバスター",
                              "ディナード",
                              "エグバート",
                              "レマイモン",
                              "コンランク",
                              "ノーマンド",
                              "ラステッド"]

    func getWinnerUserName() -> String {
        let count = nameList.count
        let index = Int.random(in: 0..<count)
        guard count > index else {
            return ""
        }
        return nameList[index]
    }
}

