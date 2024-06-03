//
//  ChatMessageCell.swift
//  kokonats
//  
//  Created by iori on 2022/03/12
//  
    

import UIKit

class ChatMessageCell: UITableViewCell {
    typealias TapHandler = (ChatMessage) -> Void
    
    // This app does not rotate, so max width is fixed.
    private static let MessageMaxWidth: CGFloat = UIScreen.main.bounds.width - LeftMargin - IconWH - IconAndNameMargin - TimeWidth - RightMargin - Padding
    private static let MessageMinWidth: CGFloat = min(152, MessageMaxWidth)
    private static let MessageMaxSize = CGSize(width: MessageMaxWidth, height: .greatestFiniteMagnitude)
    private static let Padding: CGFloat = 14
    private static let LeftMargin: CGFloat = 35
    private static let RightMargin: CGFloat = 35
    private static let IconWH: CGFloat = 48
    private static let IconAndNameMargin: CGFloat = 10
    private static let NameHeight: CGFloat = 20
    private static let NameAndMessageMargin: CGFloat = 4
    private static let TimeWidth: CGFloat = 30
    private static let MessageDefaultHeight: CGFloat = 30

    private var iconView: UIImageView = .init(frame: .zero)
    private var nameLabel: UILabel = .formatedLabel(size: 14, type: .medium, textAlignment: .left)
    private var timeLabel: UILabel = .formatedLabel(size: 11, type: .regular, textAlignment: .right)
    private lazy var messageLabel: UILabel = Self.buildMesssageLabel()
    private var messageHeightConstraint: NSLayoutConstraint!
    private var messageWidthConstraint: NSLayoutConstraint!
    
    private var message: ChatMessage?
    private var didTapHandler: TapHandler?
    
    private static func buildMesssageLabel(text: String? = nil) -> UILabel {
        let label: UILabel = .formatedLabel(size: 14, text: "", type: .regular, textAlignment: .left)
        label.numberOfLines = 0
        return label
    }
    
    static func calcHeight(body: String) -> CGFloat {
        // NOTE: must always be the same as messageLabel
        let label = buildMesssageLabel(text: body)
        return max(label.sizeThatFits(MessageMaxSize).height, MessageDefaultHeight) + NameHeight + NameAndMessageMargin + (Padding / 2)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(iconView)
        iconView.activeSelfConstrains([.height(Self.IconWH), .width(Self.IconWH)])
        iconView.activeConstraints(to: contentView, directions: [.top(.top, 4), .leading(.leading, Self.LeftMargin)])
        iconView.cornerRadius = Self.IconWH / 2
        iconView.backgroundColor = .kokoBgGray2
        iconView.isUserInteractionEnabled = true

        contentView.addSubview(nameLabel)
        nameLabel.activeSelfConstrains([.height(Self.NameHeight)])
        nameLabel.activeConstraints(to: contentView, directions: [.top(), .trailing(.trailing, -Self.TimeWidth - Self.RightMargin)])
        nameLabel.activeConstraints(to: iconView, directions: [.leading(.trailing, Self.IconAndNameMargin)])
        
        contentView.addSubview(timeLabel)
        timeLabel.activeSelfConstrains([.width(Self.TimeWidth), .height(16)])
        timeLabel.activeConstraints(to: contentView, directions: [.trailing(.trailing, -Self.RightMargin)])
        timeLabel.activeConstraints(to: nameLabel, directions: [.centerY])
        
        contentView.addSubview(messageLabel)
        messageLabel.backgroundColor = .textBgColor
        messageLabel.cornerRadius = 6
        // will be updated
        messageHeightConstraint = messageLabel.heightAnchor.constraint(equalToConstant: 0)
        messageHeightConstraint.isActive = true
        messageWidthConstraint = messageLabel.widthAnchor.constraint(equalToConstant: 0)
        messageWidthConstraint.isActive = true
        messageLabel.activeConstraints(to: nameLabel, directions: [.leading(), .top(.bottom, Self.NameAndMessageMargin)])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        message = nil
        didTapHandler = nil
        iconView.image = nil
        nameLabel.text = nil
        messageLabel.text = nil
        iconView.gestureRecognizers?.forEach {
            iconView.removeGestureRecognizer($0)
        }
    }
    
    func configure(message: ChatMessage, didTap: TapHandler? = nil) {
        self.message = message
        if let authorId = message.author.id, authorId == 0 {
            // set fixed icon when author is CS
            iconView.image = UIImage(named: "AppIcon")
        } else {
            iconView.image = UIImage(named: "avatar_" + (message.author.picture ?? "") + "")
        }
        nameLabel.text = message.author.userName
        timeLabel.text = message.sentAt.kokoChatFormated()
        messageLabel.text = message.body
        
        if let userId = message.author.id, let meId = AppData.shared.currentUser?.id, ![meId, ChatManager.CS_ID].contains(userId) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapIcon))
            iconView.addGestureRecognizer(tap)
            didTapHandler = didTap
        }
        
        updateMessageConstraint()
    }
    
    private func updateMessageConstraint() {
        let size = messageLabel.sizeThatFits(Self.MessageMaxSize)
        let adjustHeight = CGFloat(min(messageLabel.numberOfLines, 5)) * Self.Padding / 5
        messageHeightConstraint.constant = size.height + adjustHeight
        messageWidthConstraint.constant = max(min(size.width + Self.Padding, Self.MessageMaxWidth), Self.MessageMinWidth)
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    @objc
    private func didTapIcon() {
        guard let message = message else { return }
        didTapHandler?(message)
    }
}
