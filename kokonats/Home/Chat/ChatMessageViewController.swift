//
//  ChatMessageViewController.swift
//  kokonats
//  
//  Created by iori on 2022/03/12
//  


import UIKit
import Typist

fileprivate struct Const {
    // This app does not rotate, so max value is fixed.
    static let BottomViewMaxHeight: CGFloat = UIFont.getKokoFont(type: .regular, size: 14).lineHeight * 4 + BottomContentMargin * 2
    static let BottomContentMargin: CGFloat = 12
    static let BottomViewDefaultHeight: CGFloat = 60
    static let MaxMessageLength: Int = 140
}

class ChatMessageViewController: UIViewController, ChatTransitionAnimatable {
    
    enum MessageType: Equatable {
        // public channel は必ず threadId が存在する
        case channel(threadId: String)
        // 自分 と user X の組み合わせ。初めて投稿する時 threadId は nil.
        case dm(threadId: String?, member: ChatMember)
        // 各ユーザー毎に document が1つあるけど、投稿するまではつくらない
        case support
    }
    
    var messageType: MessageType { return dataSource.type }
    var targetView: UIView { return backButton } // ChatTransitionAnimatable
    private var backButton = UIButton(type: .custom)
    private var roomNameLabel = UILabel.formatedLabel(size: 15, type: .bold, textAlignment: .center)
    private var topView = UIView(frame: .zero)
    private var topViewHeight: CGFloat = ChatElementListViewController.TopViewHeight
    private var tableView = UITableView(frame: .zero)
    private var bottomView = UIView(frame: .zero)
    // will change when user enters / deletes a line
    private var bottomViewHeightConstraint: NSLayoutConstraint!
    // will change when keyboard shows / hides
    private var bottomViewBottomConstraint: NSLayoutConstraint!
    private var textView = UITextView(frame: .zero)
    private var textViewInsets = UIEdgeInsets(top: 4, left: 8, bottom: 0, right: 8)
    private var textLengthLabel = UILabel(frame: .zero)
    private var submitButton = UIButton(type: .custom)
    private var dataSource: ChatMessageDataSource!
    
    static func instantiate(type: MessageType) -> Self {
        let vc = Self()
        vc.dataSource = ChatMessageDataSource(type: type, delegate: vc)
        return vc
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // observe keyboard
        Typist.shared
            .on(event: .willShow, do: { [weak self] options in
                self?.updateBottomConstraint(-options.endFrame.height, animated: true)
            })
            .on(event: .didShow, do: { [weak self] options in
                self?.updateBottomConstraint(-options.endFrame.height)
            })
            .on(event: .willHide, do: { [weak self] _ in
                self?.updateBottomConstraint(0, animated: true)
            })
            .on(event: .didHide, do: { [weak self] _ in
                self?.updateBottomConstraint(0)
            })
            .start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.startListening()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateBottomConstraint(0)
        dataSource.stopListening()
    }
    
    // MARK: - setup layout
    private func setup() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .clear
        
        setupNavbarIfNeeded()
        setupTableView()
        setupBottomView()
    }
    
    private func setupNavbarIfNeeded() {
        // NOTE: if nav does not exist, it means support tab's vc
        guard let _ = navigationController else {
            topViewHeight = 0
            return
        }
        view.addSubview(topView)
        topView.activeSelfConstrains([.height(topViewHeight)])
        topView.activeConstraints(to: view, directions: [.top(), .leading(), .trailing()])
        backButton.setImage(UIImage(named: "nav_back"), for: .normal)
        backButton.addTarget(self, action: #selector(self.didTapBackButton), for: .touchUpInside)
        topView.addSubview(backButton)
        let margin: CGFloat = 35
        let wh: CGFloat = 40
        backButton.activeSelfConstrains([.width(wh), .height(wh)])
        backButton.activeConstraints(to: topView, directions: [.centerY, .leading(.leading, margin)])
        topView.addSubview(roomNameLabel)
        roomNameLabel.activeConstraints(to: topView, directions: [.top(), .bottom(), .centerX, .trailing(.trailing, -(margin + wh))])
        roomNameLabel.activeConstraints(to: backButton, directions: [.leading(.trailing, 0)])
        dataSource.getThreadName { [weak self] name in
            self?.roomNameLabel.text = name
        }
    }
    
    private func setupTableView() {
        dataSource.registerCells(tableView) { [weak self] in
            self?.tableView.reloadData()
        }
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        // bottom constraint will be set by bottomView
        tableView.activeConstraints(to: view, directions: [.top(.top, topViewHeight), .leading(), .trailing()])
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tableView.addGestureRecognizer(tap)
    }
    
    private func setupBottomView() {
        bottomView.backgroundColor = .kokoBgColor
        view.addSubview(bottomView)
        bottomView.activeConstraints(to: tableView, directions: [.top(.bottom, 0)])
        bottomView.activeConstraints(to: view, directions: [.bottom(), .leading(), .trailing()])
        // will be changed by keyboard shows / hides
        bottomViewBottomConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        bottomViewBottomConstraint.isActive = true
        // will be changed when user enters / deletes a line
        bottomViewHeightConstraint = bottomView.heightAnchor.constraint(equalToConstant: Const.BottomViewDefaultHeight)
        bottomViewHeightConstraint.isActive = true
        
        submitButton.setImage(UIImage(named: "submit_button"), for: .normal)
        submitButton.tintColor = .white
        submitButton.isEnabled = false
        bottomView.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(self.didTapSubmitButton), for: .touchUpInside)
        submitButton.activeSelfConstrains([.width(28), .height(28)])
        submitButton.activeConstraints(to: bottomView, directions: [.bottom(.bottom, -Const.BottomContentMargin), .trailing(.trailing, -35)])
        
        bottomView.addSubview(textView)
        textView.delegate = self
        textView.textContainerInset = textViewInsets
        textView.font = .getKokoFont(type: .regular, size: 14)
        textView.textColor = .white
        textView.backgroundColor = .textBgColor
        textView.cornerRadius = 14
        // 適切な height 以下だと iOS 15 で入力のたびにずれる
        textView.activeConstraints(to: bottomView, directions: [.top(.top, 6), .bottom(.bottom, -Const.BottomContentMargin), .leading(.leading, 35)])
        textView.activeConstraints(to: submitButton, directions: [.trailing(.leading, -25)])
        
        bottomView.addSubview(textLengthLabel)
        textLengthLabel.textAlignment = .right
        textLengthLabel.font = .getKokoFont(type: .regular, size: 10)
        textLengthLabel.textColor = .kokoBgGray
        textLengthLabel.activeSelfConstrains([.width(100), .height(10)])
        textLengthLabel.activeConstraints(to: textView, directions: [.bottom(.bottom, -2), .trailing(.trailing, -10)])
    }
    
    private func updateBottomConstraint(_ constant: CGFloat, animated: Bool = false) {
        bottomViewBottomConstraint.constant = constant
        view.setNeedsLayout()
        if !animated {
            view.layoutIfNeeded()
            return
        }
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func updateTextViewHeightIfNeeded() {
        // NOTE: no need to think of textViewInsets
        let maxSize = CGSize(width: textView.frame.width, height: Const.BottomViewMaxHeight)
        let fitSize = textView.sizeThatFits(maxSize)
        let height = max(min(fitSize.height, Const.BottomViewMaxHeight) + Const.BottomContentMargin * 2, Const.BottomViewDefaultHeight)
        bottomViewHeightConstraint.constant = height
    }
    
    // MARK: - actions
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapSubmitButton() {
        guard let text = textView.text else { return }
        dataSource.submit(text: text) { [weak self] success in
            if success {
                self?.textView.text = nil
                self?.updateTextViewHeightIfNeeded()
                self?.tableView.scrollToBottom()
            }
        }
    }
}

extension ChatMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource.getCellHeight(for: indexPath)
    }
}

extension ChatMessageViewController: ChatMessageDelegate {
    typealias MType = ChatMessageViewController.MessageType
    func didTapIcon(message: ChatMessage) {
        if case .dm(_,_) = messageType, let member = dataSource.members.first, member == message.author {
            return
        }
        NotificationCenter.default.post(name: .needToSwitchChatTab, object: MType.dm(threadId: nil, member: message.author))
    }
}

extension ChatMessageViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let isLoggedIn = AppData.shared.isLoggedIn()
        if !isLoggedIn {
            showErrorMessage(title: "error_need_to_login_first".localized, reason: "")
        }
        return isLoggedIn
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = String(textView.text.prefix(Const.MaxMessageLength))
        textLengthLabel.text = "\(textView.text.count)/\(Const.MaxMessageLength)"
        textLengthLabel.isHidden = textView.text.isEmpty
        updateTextViewHeightIfNeeded()
        submitButton.isEnabled = textView.text != nil && !textView.text!.isEmpty
    }
}
