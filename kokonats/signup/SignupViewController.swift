////  SignupViewController.swift
//  kokonats
//
//  Created by sean on 2021/10/07.
//  
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Firebase
import GoogleSignIn


final class SignupViewController: UIViewController {

    enum SignUpActionType {
        case apple
        case google
    }

    static var shared = SignupViewController()

    // Unhashed nonce.
    private var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        let signupView = SignupView()
        view.backgroundColor = .kokoBgColor
        view.addSubview(signupView)
        signupView.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.top(), .leading(), .bottom(), .trailing()])
        signupView.eventHandler = self
    }

    private func signInWithApple() {
        let nonce = SignInWithAppleHelper.randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = SignInWithAppleHelper.sha256(nonce)


        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func signInWithGoogle() {
        // TODO: (update it to production)
        let config = GIDConfiguration(clientID: "740600456391-9jtbomvqgqj95qbvsrhhffhkkdl7cctl.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
            if let user = user, error == nil {
                // TODO: save it in keychain.
                LocalStorageManager.idToken = user.authentication.idToken ?? ""
                LocalStorageManager.googleUserId = user.userID ?? ""
                self?.handleLoginInfo(name: user.profile?.name,
                                      email: user.profile?.email,
                                      idToken: user.authentication.idToken ?? "",
                                      type: .google)
            } else{
                Logger.debug("debug " + error.debugDescription)
            }
        }
    }

    private func handleLoginInfo(name: String?, email: String?, idToken: String, type: LoginType) {
        // User is signed in to Firebase with Apple.
        // TODO <sean> do we need to update user name/email to firebase?
        name.flatMap { LocalStorageManager.fullName = $0.description }
        email.flatMap { LocalStorageManager.email = $0 }

        ApiManager.shared.loginToKoko(idToken: idToken, type: type) { result in
            switch result {
            case .success(let userInfo):
                AppData.shared.currentUser = userInfo
                NotificationCenter.default.post(name: .userLoggedIn, object: nil)
            default:
                break
            }
        }
    }

    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest()]

        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

}

protocol SignupEventHandler {
    func signupEvent(type: SignupViewController.SignUpActionType)
    func cancelEvent()
}

extension SignupViewController: SignupEventHandler {
    func signupEvent(type: SignUpActionType) {
        switch type {
        case .apple:
            signInWithApple()
        case .google:
            signInWithGoogle()
        }
    }
  
    func cancelEvent() {
        NotificationCenter.default.post(name: .userCanceledLogin, object: nil)
    }
}


// MARK: extension for sign in with apple

extension SignupViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let nonce = currentNonce else {
//              fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }

            // Create an account in your system.
            let userIdentifier = appleIDCredential.user

            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
              Logger.debug("Unable to fetch identity token")
              return
            }

            // save id token
            // TODO: save it in keychain.
            LocalStorageManager.idToken = idTokenString
            LocalStorageManager.appleUserId = userIdentifier
            saveUserInKeychain(userIdentifier)

            handleLoginInfo(name: appleIDCredential.fullName?.description,
                            email: appleIDCredential.email,
                            idToken: idTokenString,
                            type: .apple)


            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nil)

            // register to Firebase.
            // https://firebase.google.com/docs/auth/ios/apple
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    return
                }
            }
        }
    }

}

extension SignupViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


// MARK: some helper function for saving cridential

extension SignupViewController {

    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.biiiiit.club-kokonats", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            Logger.debug("Unable to save userIdentifier to keychain.")
        }
    }

    private func deleteUserInKeychain() {
        do {
            try KeychainItem(service: "com.biiiiit.club-kokonats", account: "userIdentifier").deleteItem()
        } catch {
            Logger.debug("failed to delete item")
        }
    }

    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        Logger.debug("Sign in with Apple errored: \(error)")
    }
}
