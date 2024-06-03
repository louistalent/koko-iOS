//  ApiManager.swift
//  kokonats
//
//  Created by sean on 2021/07/18.
//  
//

import Foundation

enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
}

enum CommonError: Error {
    case badNetwork
    case connectionFailure
    case badData
    case authenticationError // 401
    case loginFailure
    case notFound // 404
    case rejectedByServer
    case unknown
    case balanceFailure
    case unexpectedStatus
    case matchNotFound
    case insufficientKokoBalance
}

// TODO: need to refactor the enum
enum Api: String {
    case appleLogin = "auth/apple/login"
    case googleLogin = "auth/google/login"
    case userInfo = "user/info"
    case gameList = "game/list"
    case gameDetail = "game"
    case test = "hello"

    func url() -> URL? {
//        let serverURL = "http://192.168.0.103:8080/"
        let serverURL = "https://kokonuts-server-gateway-jx-staging.kokonats.club/"
        return URL(string: serverURL + self.rawValue)
    }
}

enum LoginType {
    case apple
    case google

    var url: URL {
        switch self {
        case .apple:
            return Api.appleLogin.url()!
        case .google:
            return Api.googleLogin.url()!
        }
    }
}

typealias JSONObject = [String: Any]

final class ApiManager {
    static let shared = ApiManager()
//    private let serverURL = "http://192.168.0.103:8080/"
    private let serverURL = "https://kokonuts-server-gateway-jx-staging.kokonats.club/"

    private let delegateQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "delegateQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    }

    private func createHTTPRequest(url: URL?, method: HttpMethod, idToken: String? = nil) -> URLRequest? {
        guard let url = url else {
            return nil
        }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
        idToken.flatMap {
            request.addValue("Bearer \($0)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch method {
        case .post:
            request.httpMethod = "POST"
            return request
        case .get:
            request.httpMethod = "GET"
            return request
        }
    }

    /// completion handler runs on MainThread
    private func send(_ request: URLRequest, completion: @escaping ((Result<Data?, CommonError>) -> Void)) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let response = response as? HTTPURLResponse else {
                Logger.debug("connection failed")
                DispatchQueue.main.async {
                    completion(.failure(.connectionFailure))
                }
                return
            }
            guard response.statusCode == 200 else {
                Logger.debug("response.statusCode: \(response.statusCode)")
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        completion(.failure(.authenticationError))
                    }
                    return
                }
                if response.statusCode == 404 {
                    Logger.debug("\(request.url?.absoluteString  ?? "")")
                    Logger.debug(response.debugDescription)
                    DispatchQueue.main.async {
                        completion(.failure(.notFound))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.failure(.rejectedByServer))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        task.resume()
    }

    func loginToKoko(idToken: String, type: LoginType, completion: @escaping (Result<UserInfo, CommonError>) -> Void) {
        let data: [String: String] = [ "idToken": idToken ]
        guard var request = createHTTPRequest(url: type.url, method: .post) else {
            completion(.failure(.connectionFailure))
            return
        }
        do {
            let postData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = postData
        } catch {
            completion(.failure(.badData))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil, let response = response as? HTTPURLResponse else {
                Logger.debug("connection failed")
                completion(.failure(.connectionFailure))
                return
            }

            guard response.statusCode == 200 else {
                Logger.debug("authenticationError: \(response.statusCode)")
                completion(.failure(.authenticationError))
                return
            }
            self?.parserUserData(result: .success(data), completion: completion)
        }
        task.resume()
    }

    func getUserInfo(idToken: String, completion: @escaping (Result<UserInfo, CommonError>) -> Void) {
        guard var request = createHTTPRequest(url: Api.userInfo.url(), method: .get) else {
            completion(.failure(.connectionFailure))
            return
        }
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "authorization")
        send(request) { [weak self] result in
            self?.parserUserData(result: result, completion: completion)
        }
    }

    private func parserUserData(result: Result<Data?, CommonError>, completion: @escaping (Result<UserInfo, CommonError>) -> Void) {
        switch result {
        case .success(let data):
            if let data = data,
               let jsonData = data.convertToJson(),
               let userInfo = UserInfo(json: jsonData) {
                AppData.shared.currentUser = userInfo
                completion(.success(userInfo))
            } else {
                completion(.failure(.unknown))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    func getTournamentClasses(idToken: String, completion: @escaping (Result<[TournamentClassDetail], CommonError>) -> Void) {
        let url = URL(string: serverURL + "tournamentClass")

        guard  var request = createHTTPRequest(url: url, method: .get) else {
            completion(.failure(.unknown))
            return
        }

        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "authorization")
        send(request) { [weak self] result in
            self?.handleTournamentDetailData(result: result, completion: completion)
        }
    }
    
    func getTournamentClasses(forGameId id: Int, completion: @escaping (Result<[TournamentClassDetail], CommonError>) -> Void) {
        // NOTE: The server has the wrong naming path.  The correct path is /game/:gameId/tournamentClasses.
        let url = URL(string: serverURL + "game/\(id)/tournaments")

        guard let request = createHTTPRequest(url: url, method: .get, idToken: LocalStorageManager.idToken) else {
            completion(.failure(.unknown))
            return
        }

        send(request) { [weak self] result in
            self?.handleTournamentDetailData(result: result, completion: completion)
        }
    }

    private func handleTournamentDetailData(result: Result<Data?, CommonError>, completion: @escaping (Result<[TournamentClassDetail], CommonError>) -> Void) {
        switch result {
        case .success(let data):
            guard let unwrappedData = data else {
                completion(.failure(.badData))
                return
            }
            do {
                let list = try JSONDecoder().decode([TournamentClassDetail].self, from: unwrappedData)
                completion(.success(list))
            } catch {
                Logger.debug("\(error)")
                completion(.failure(.badData))
                return
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    /// getPlayable
    func getPlayableTournament(tournamentId: String, idToken: String, completion: @escaping (Result<PlayableTournamentDetail, CommonError>) -> Void) {
        let url = URL(string: serverURL + "tournamentClass/\(tournamentId)/tournament")
        guard var request = createHTTPRequest(url: url, method: .get) else {
            completion(.failure(.unknown))
            return
        }

        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "authorization")
        send(request) { result in
            switch result {
            case .success(let data):
                guard let unwrappedData = data else {
                    completion(.failure(.badData))
                    return
                }
                do {
                    let list = try JSONDecoder().decode(PlayableTournamentDetail.self, from: unwrappedData)
                    completion(.success(list))
                } catch {
                    Logger.debug("\(error)")
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTournamentHistories(tounamentClassId id: Int, completion: @escaping (Result<[PlayableTournamentDetail], CommonError>) -> Void) {
        let url = URL(string: serverURL + "tournamentClass/\(id)/history")

        guard let request = createHTTPRequest(url: url, method: .get, idToken: LocalStorageManager.idToken) else {
            completion(.failure(.unknown))
            return
        }

        send(request) { result in
            switch result {
            case .success(let data):
                guard let unwrappedData = data else {
                    completion(.failure(.badData))
                    return
                }
                do {
                    let list = try JSONDecoder().decode([PlayableTournamentDetail].self, from: unwrappedData)
                    completion(.success(list))
                } catch {
                    Logger.debug("\(error)")
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getGamesList(idToken: String, completion: @escaping (Result<[GameDetail], CommonError>) -> Void) {
        let url = URL(string: serverURL + "game/list")
        guard let request = createHTTPRequest(url: url, method: .get, idToken: idToken) else {
            return completion(.failure(.unknown))
        }
        send(request) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.badData))
                    return
                }
                do {
                    let gameList = try JSONDecoder().decode([GameDetail].self, from: data)
                    completion(.success(gameList))
                } catch {
                    Logger.debug("\(error)")
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getGameInfo(gameId: String, idToken: String, completion: @escaping (Result<GameDetail, CommonError>) -> Void) {
        let url = URL(string: serverURL + "game/\(gameId)")
        guard let request = createHTTPRequest(url: url, method: .get, idToken: idToken)  else {
            return completion(.failure(.unknown))
        }

        send(request) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.badData))
                    return
                }
                do {
                    let gameDetail = try JSONDecoder().decode(GameDetail.self, from: data)
                    completion(.success(gameDetail))
                } catch {
                    Logger.debug("\(error)")
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getGameAuth(gameId: Int, completion: @escaping (Result<String, CommonError>) -> Void) {
        let url = URL(string: serverURL + "user/game/auth")
        guard var request = createHTTPRequest(url: url, method: .post, idToken: LocalStorageManager.idToken) else {
            return completion(.failure(.unknown))
        }

        do {
            let data: JSONObject = [ "gameId": gameId ]
            let postData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = postData
        } catch {
            completion(.failure(.badData))
            return
        }

        send(request) { result in
            switch result {
            case .success(let data):
                guard let jsonData = data?.convertToJson(),
                      let gameAuth = jsonData["token"] as? String else {
                    completion(.failure(.badData))
                    return
                }
                completion(.success(gameAuth))
                return
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    ///https://kokonuts-server-gateway-jx-staging.kokonats.club/tournament/1/plays'
    func getTournamentRanking(tournamentId: String, idToken: String, completion: @escaping (Result<[TournamentPlay], CommonError>) -> Void) {
        let url = URL(string: serverURL + "tournament/\(tournamentId)/plays")
        guard let request = createHTTPRequest(url: url, method: .get, idToken: idToken) else {
            return completion(.failure(.unknown))
        }

        send(request) { [weak self] result in
            self?.parseTournamentPlay(result: result, completion: completion)
        }
    }

    func joinTournament(tournamentId: String, idToken: String, completion: @escaping (Result<TournamentPlay, CommonError>) -> Void) {
        let url = URL(string: serverURL + "user/tournament/play")
        guard var request = createHTTPRequest(url: url, method: .post, idToken: idToken) else {
            return completion(.failure(.unknown))
        }
        do {
            let data: JSONObject = [ "tournamentId": tournamentId ]
            let postData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = postData
        } catch {
            completion(.failure(.badData))
            return
        }

        send(request) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let hisotry = try JSONDecoder().decode(TournamentPlay.self, from: data)
                    completion(.success(hisotry))
                } catch {
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getTournamenHistory(idToken: String, completion: @escaping (Result<[UserTournamentHistoryItem], CommonError>) -> Void) {
        let url = URL(string: serverURL + "user/tournament/plays")
        guard let request = createHTTPRequest(url: url, method: .get, idToken: idToken) else {
            return completion(.failure(.unknown))
        }

        send(request) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let hisotry = try JSONDecoder().decode([UserTournamentHistoryItem].self, from: data)
                    completion(.success(hisotry))
                } catch {
                    Logger.debug(error.localizedDescription)
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func parseTournamentPlay(result: Result<Data?, CommonError>, completion: @escaping (Result<[TournamentPlay], CommonError>) -> Void) {
        switch result {
        case .success(let data):
            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            do {
                let hisotry = try JSONDecoder().decode([TournamentPlay].self, from: data)
                completion(.success(hisotry))
            } catch {
                completion(.failure(.badData))
                return
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    func getEnergyBalance(idToken: String, completion: @escaping (Result<Int, CommonError>) -> Void) {
        let url = URL(string: serverURL + "energy/balance")

        guard let request = createHTTPRequest(url: url, method: .get, idToken: idToken) else {
            return completion(.failure(.unknown))
        }

        send(request) { result in
            switch result {
            case .success(let data):
                guard  let data = data else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let energy = try JSONDecoder().decode(Int.self, from: data)
                    completion(.success(energy))
                } catch {
                    completion(.failure(.badData))
                    return
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func verifyReceipt(idToken: String, transactionId: String, receipt: String, completion: @escaping (Result<VerificationResult, CommonError>) -> Void) {
        let url = URL(string: serverURL + "energy/purchase")
        var request = createHTTPRequest(url: url, method: .post, idToken: idToken)!
        do {
            let data: JSONObject = [
                "platform": "apple",
                "receipt": receipt,
                "transactionId": transactionId
            ]
            let postData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = postData
        } catch {
            completion(.failure(.badData))
            return
        }

        send(request) { result in
            switch result {
            case .success(let rawResult):
                guard let rawResult = rawResult else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(VerificationResult.self, from: rawResult)
                    completion(.success(result))
                } catch {
                    completion(.failure(.badData))
                    return
                }

            case .failure(let error):
                Logger.debug("failed to verify receipt: \(error)")
                completion(.failure(.unknown))
            }
        }
    }

    func getKokoBalance(idToken: String, completion: @escaping (Result<KokoBalance, CommonError>) -> Void) {
        let url = URL(string: serverURL + "wallet/balance")
        let request = createHTTPRequest(url: url, method: .get, idToken: idToken)!

        send(request) { result in
            switch result {
            case .success(let rawData):
                guard let rawData = rawData else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(KokoBalance.self, from: rawData)
                    completion(.success(result))
                } catch {
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                Logger.debug("failed to verify receipt: \(error)")
                completion(.failure(.balanceFailure))
            }
        }
    }

    // MARK: PVP

    //https://kokonuts-server-gateway-jx-staging.kokonats.club/game/3/matches
    func getPVPMatches(idToken: String, gameId: Int, completion: @escaping (Result<[GameMatch], CommonError>) -> Void) {
        let url = URL(string: serverURL + "game/\(gameId)/matches")
        let request = createHTTPRequest(url: url, method: .get, idToken: idToken)!

        send(request) { result in
            switch result {
            case .success(let rawData):
                guard let rawData = rawData else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode([GameMatch].self, from: rawData)
                    completion(.success(result))
                } catch {
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                Logger.debug("failed to verify receipt: \(error)")
                completion(.failure(.rejectedByServer))
            }
        }
    }

    func startSession(idToken: String, matchClassId: Int, completion: @escaping (Result<String, CommonError>) -> Void) {
        let url = URL(string: serverURL + "matchClass/\(matchClassId)/session")
        let request = createHTTPRequest(url: url, method: .post, idToken: idToken)!

        send(request) { result in
            switch result {
            case .success(let data):
                guard let jsonData = data?.convertToJson(),
                      let sessionId = jsonData["sessionId"] as? String else {
                    completion(.failure(.badData))
                    return
                }
                completion(.success(sessionId))
                return
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    //https://kokonuts-server-gateway-jx-staging.kokonats.club/matchClass/session/{sessionId}
    func getSessionResult(idToken: String, sessionId: Int, completion: @escaping (Result<SessionResult, CommonError>) -> Void) {
        let url = URL(string: serverURL + "matchClass/session/\(sessionId)")
        let request = createHTTPRequest(url: url, method: .get, idToken: idToken)!

        send(request) { result in
            switch result {
            case .success(let rawData):
                guard let rawData = rawData else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(SessionResult.self, from: rawData)
                    completion(.success(result))
                } catch {
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                Logger.debug("getSessionResult failure: \(error)")
                completion(.failure(error))
            }
        }
    }

    //https://kokonuts-server-gateway-jx-staging.kokonats.club/match/{matchPlayId}
    func getMatchResult(idToken: String, matchPlayId: Int, completion: @escaping (Result<MatchResult, CommonError>) -> Void) {
        let url = URL(string: serverURL + "match/\(matchPlayId)")
        let request = createHTTPRequest(url: url, method: .get, idToken: idToken)!
        send(request) { result in
            switch result {
            case .success(let rawData):
                guard let rawData = rawData else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(MatchResult.self, from: rawData)
                    completion(.success(result))
                } catch {
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                Logger.debug("getMatchResult failure: \(error)")
                completion(.failure(error))
            }
        }
    }

    func getPurchasedGameItems(idToken: String, completion: @escaping (Result<[PurchasedGameItem], CommonError>) -> Void) {
        let url = URL(string: serverURL + "user/consume/item")
        let request = createHTTPRequest(url: url, method: .get, idToken: idToken)!
        send(request) { result in
            switch result {
            case .success(let rawData):
                guard let rawData = rawData else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode([PurchasedGameItem].self, from: rawData)
                    completion(.success(result))
                } catch {
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                Logger.debug("getMatchResult failure: \(error)")
                completion(.failure(error))
            }
        }
    }

    func getGameItems(idToken: String, gameId: String, completion: @escaping (Result<[GameItem], CommonError>) -> Void) {
        let url = URL(string: serverURL + "game/\(gameId)/items")
        let request = createHTTPRequest(url: url, method: .get, idToken: idToken)!
        send(request) { result in
            switch result {
            case .success(let rawData):
                guard let rawData = rawData else {
                    completion(.failure(.badData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode([GameItem].self, from: rawData)
                    completion(.success(result))
                } catch {
                    completion(.failure(.badData))
                    return
                }
            case .failure(let error):
                Logger.debug("getMatchResult failure: \(error)")
                completion(.failure(error))
            }
        }
    }

    func exchangeGameItem(idToken: String, gameItemId: Int, completion: @escaping (Result<Int, CommonError>) -> Void) {
        let url = URL(string: serverURL + "user/consume/item")

        var request = createHTTPRequest(url: url, method: .post, idToken: idToken)!

        do {
            let data: JSONObject = [
                "gameItemId": gameItemId
            ]
            let postData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = postData
        } catch {
            completion(.failure(.badData))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let response = response as? HTTPURLResponse else {
                Logger.debug("connection failed")
                DispatchQueue.main.async {
                    completion(.failure(.connectionFailure))
                }
                return
            }
            guard (response.statusCode == 201 || response.statusCode == 200), let data = data else {
                Logger.debug("response.statusCode: \(response.statusCode)")
                if response.statusCode == 403 {
                    DispatchQueue.main.async {
                        completion(.failure(.insufficientKokoBalance))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.failure(.rejectedByServer))
                }

                return
            }

            do {
                let result = try JSONDecoder().decode(Int.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.badData))
                return
            }
        }
        task.resume()
    }
    
    func editProfile(idToken: String, userName: String, picture: Int, completion: @escaping (Result<UserInfo, CommonError>) -> Void) {
        guard var request = createHTTPRequest(url: Api.userInfo.url(), method: .post, idToken: idToken) else {
            completion(.failure(.connectionFailure))
            return
        }
        do {
            let data: JSONObject = [
                "userName": userName,
                "picture": "\(picture)"
            ]
            let postData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = postData
        } catch {
            completion(.failure(.badData))
            return
        }
        
        send(request) { [weak self] result in
            self?.parserUserData(result: result, completion: completion)
        }
        
    }
}

extension Data {
    func convertToJson() -> JSONObject? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed) as? JSONObject
        } catch {
            return nil
        }
    }
}
