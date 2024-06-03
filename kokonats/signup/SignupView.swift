////  SignupView.swift
//  kokonats
//
//  Created by sean on 2021/10/07.
//  
//

import UIKit
import AuthenticationServices
import GoogleSignIn

final class SignupView: UIView {

    private var googleSignupView: UIImageView!
    private var appleSignupButton: ASAuthorizationAppleIDButton!
    var eventHandler: SignupEventHandler?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .kokoBgColor
        // FIXME: replace close icon
        let closeButton = UIButton(type: .close)
        addSubview(closeButton)
        closeButton.activeConstraints(directions: [.top(.top, 24), .leading(.leading, 12)])
        closeButton.activeSelfConstrains([.width(30), .height(30)])
        closeButton.addTarget(self, action: #selector(self.closeAction), for: .touchUpInside)
      
        let kokoLogo = UIImageView(image: UIImage(named: "new_k_log"))
        addSubview(kokoLogo)
        kokoLogo.activeConstraints(directions: [.top(.top, 88), .centerX])
        kokoLogo.activeSelfConstrains([.width(87), .height(90)])
        let descriptionLabel = UILabel.formatedLabel(size: 28, text: "アカウント作成")
        addSubview(descriptionLabel)
        descriptionLabel.activeConstraints(to: self, directions: [.centerX, .leading(), .trailing()])
        descriptionLabel.activeConstraints(to: kokoLogo, directions: [.top(.bottom, 55)])
        descriptionLabel.activeSelfConstrains([.height(38)])

        let appleSignupButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                                               authorizationButtonStyle: .white)
        addSubview(appleSignupButton)
        appleSignupButton.activeConstraints(to: descriptionLabel, directions: [.top(.bottom, 51)])
        appleSignupButton.activeConstraints(to: kokoLogo, directions: [.centerX])
        appleSignupButton.activeSelfConstrains([.height(48), .width(295)])
        appleSignupButton.addTarget(self, action: #selector(signInWithAppleAction), for: .touchUpInside)
        self.appleSignupButton = appleSignupButton

        let googleSignup = UIImageView(image: UIImage(named: "google_signup"))
        addSubview(googleSignup)
        googleSignup.activeConstraints(to: appleSignupButton, directions: [.top(.bottom, 30)])
        googleSignup.activeConstraints(to: self, directions: [.centerX])
        googleSignup.activeSelfConstrains([.height(68), .width(68)])
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.signInWithGoogleAction))
        googleSignup.addGestureRecognizer(tapGR)
        googleSignup.isUserInteractionEnabled = true
        self.googleSignupView = googleSignup
    }


    @objc private func signInWithAppleAction() {
        eventHandler?.signupEvent(type: .apple)
        Logger.debug("signInWithAppleAction ")
    }

    @objc private func signInWithGoogleAction() {
        eventHandler?.signupEvent(type: .google)
    }
  
    @objc private func closeAction() {
        eventHandler?.cancelEvent()
    }
}
