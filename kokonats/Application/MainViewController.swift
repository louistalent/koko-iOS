//
//  MainViewController.swift
//  kokonats
//
//  Created by sean on 2021/07/12.
//

import UIKit
import Firebase
import AuthenticationServices

var usingDebuggingToken: Bool = false
var debug: Bool = true
var debugPurchasing: Bool = false
var debugSimulator: Bool = false
var usingLocalPage: Bool = true

class MainViewController: UITabBarController {
    var home = HomeViewController()
    var signupVC = SignupViewController()
//    var engergyStoreVC = StoreViewController()
    var engergyStoreVC = StoreNewViewController()
    var userProfileVC = UserProfileViewController()
    var backIndex: Int? = nil // to back to a vc when user canceled sign-in
    private var chatButton = UIButton(type: .custom)


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kokoBgColor
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidCancelLogin), name: .userCanceledLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout), name: .logout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen), name: .needLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEnergyStore), name: .showEnergyStore, object: nil)

        if debugSimulator {
            showMainUI()
            return
        }

        engergyStoreVC.tabBarItem = TabBarItem(type: .store)
        home.tabBarItem = TabBarItem(type: .home)
        userProfileVC.tabBarItem = TabBarItem(type: .user)
        setViewControllers([engergyStoreVC, home, userProfileVC], animated: false)
        view.backgroundColor = .kokoBgColor
        tabBar.isTranslucent = false
        tabBar.barTintColor = .kokoBgColor
        selectedIndex = 1
        
        // NOTE: chatButton is a floating button. make sure view hierarchy.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.view.addSubview(self.chatButton)
            let tabHeight = self.tabBar.frame.height
            self.chatButton.activeSelfConstrains([.width(60), .height(60)])
            // tabBar 自体が safeAreaLayoutGauide の分を含んでいるため self.view を指定する
            self.chatButton.activeConstraints(to: self.view, directions: [.trailing(.trailing, -20), .bottom(.bottom, -(tabHeight + 10))])
            self.chatButton.setImage(UIImage(named: "chat_button"), for: .normal)
            self.chatButton.addTarget(self, action: #selector(self.didTapChatButton), for: .touchUpInside)
        }
        
//        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: LocalStorageManager.appleUserId) { [weak self] (credentialState, error) in
//            showMainUI()
//            switch credentialState {
//            case .authorized where !LocalStorageManager.appleUserId.isEmpty:
//                DispatchQueue.main.async {
//                    SignupViewController.shared.performExistingAccountSetupFlows()
//
//                    self?.showMainUI()
//                }
//            default:
//                DispatchQueue.main.async {
//                    self?.showSignup()
//                }
//            }
//        }

        StoreManager.shared.fetchProductsIfNeeded()
    }

    private func showMainUI(selectedIndex: Int? = nil) {
        setViewControllers([engergyStoreVC, home, userProfileVC], animated: false)
        if let selectedIndex = selectedIndex {
            self.selectedIndex = selectedIndex
        }
    }

    @objc private func showEnergyStore() {
        DispatchQueue.main.async {
            self.selectedIndex = 0
        }
    }
    
    
    @objc private func userDidLogin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showMainUI(selectedIndex: 1)
            self.signupVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func userDidLogout() {
        DispatchQueue.main.async {
            self.selectedIndex = 1
        }
    }
  
    @objc private func userDidCancelLogin() {
        DispatchQueue.main.async {
            self.backIndex.flatMap {
                self.selectedIndex = $0
            }
            self.signupVC.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func showLoginScreen() {
        backIndex = selectedIndex
        DispatchQueue.main.async {
            self.showSignup()
        }
    }
    
    @objc
    private func didTapChatButton() {
        let chatListVC = ChatListContainerViewController()
        chatListVC.modalPresentationStyle = .overFullScreen
        show(chatListVC, sender: nil)
    }

    private func showSignup() {
        signupVC.modalPresentationStyle = .fullScreen
        self.selectedViewController?.show(signupVC, sender: self)
    }

    private func buildVC(from storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(storyboardName)ViewController")
    }
}

extension UIStoryboard {
    static func buildVC(from storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(storyboardName)ViewController")
    }
}

extension Notification.Name {
    static let userLoggedIn = Notification.Name("userLoggedIn")
    static let needLogin = Notification.Name("needLogin")
    static let logout = Notification.Name("logout")
    static let kokoPurchased = Notification.Name("kokoPurchased")
    static let failedPurchaseKoko = Notification.Name("failedPurchaseKoko")
    static let showEnergyStore = Notification.Name("showEnergyStore")
    static let userCanceledLogin = Notification.Name("userCanceledLogin")
    static let needToSwitchChatTab = Notification.Name("needToSwitchChatTab")
}
