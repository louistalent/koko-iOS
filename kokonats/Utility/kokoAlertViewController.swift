////  KokoAlertViewController.swift
//  kokonats
//
//  Created by Pedro Diaz on 2022/04/22.
//
//

import Foundation
import UIKit

class kokoViewController: UIViewController  {
    
    let modalPopup = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }

    private func configureLayout() {
        
        modalPopup.translatesAutoresizingMaskIntoConstraints = false
        modalPopup.backgroundColor = .white
        
        modalPresentationStyle = .fullScreen
        view.addSubview(modalPopup)
        view.backgroundColor = .white.withAlphaComponent(0)
        view.cornerRadius = 12
        view.isUserInteractionEnabled = true
        
        let background = UIImageView()
        modalPopup.addSubview(background)
        background.activeConstraints( to: modalPopup,directions: [ .leading(.leading, 50), .top(.top, 323 ), .trailing(.trailing,-50)])
        background.image = UIImage(named: "tournament_entryfee_background.png")
        background.activeSelfConstrains([.height(295)])
        background.activeSelfConstrains([.width(295)])
        
        let question = UIImageView()
        modalPopup.addSubview(question)
        question.activeConstraints(to: modalPopup, directions: [ .centerX, .top(.top, 360)])
        question.image = UIImage(named: "tournament_entryfee_question.png")
        question.activeSelfConstrains([.height(50)])
        
        let msgtitle = UILabel()
        modalPopup.addSubview(msgtitle)
        msgtitle.font = UIFont.getKokoFont(type: .bold, size: 20)
        msgtitle.text = "alert_entryfee_title".localized
        msgtitle.textAlignment = .center
        msgtitle.numberOfLines = 1
        msgtitle.activeConstraints(to: modalPopup,directions: [.centerX,.top(.top, 425)])
        msgtitle.activeSelfConstrains([.height(27)])

        var content = UILabel()
        content = UILabel.formatedLabel(size: 14, text: "alert_entryfee_content".localized, type: .medium)
        content.textColor = .black
        content.textAlignment = .center
        content.lineBreakMode = .byWordWrapping
        content.numberOfLines = 2
        modalPopup.addSubview(content)
        content.activeConstraints(directions: [.centerX,.top(.top, 462)])
        content.activeSelfConstrains([.height(37)])
     
        let backButton = UIButton()
        modalPopup.addSubview(backButton)
        backButton.activeConstraints( to: modalPopup,directions: [.leading(.leading, 98), .top(.top, 525)])
        backButton.setImage(UIImage(named: "tournament_entryfee_back"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        let okButton = UIButton()
        modalPopup.addSubview(okButton)
        okButton.activeConstraints( to: modalPopup,directions: [.leading(.leading, 218), .top(.top, 525)])
        okButton.setImage(UIImage(named: "tournament_entryfee_ok"), for: .normal)
        okButton.addTarget(self, action: #selector( goOk ), for: .touchUpInside)
    }
    
        @objc func goBack(_ sender: UIButton) {
            dismiss(animated: true)
        }

        @objc func goOk(_ sender: UIButton) {
            dismiss(animated: true)
        }
    
}



