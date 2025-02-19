//
//  ChatElementCell.swift
//  kokonats
//
//  Created by iori on 2022/03/06.
//

import UIKit

class ChatElementCell: UITableViewCell {
    
    private var iconView: UIImageView = .init(frame: .zero)
    private var nameLabel: UILabel = .formatedLabel(size: 14, type: .medium, textAlignment: .left)
    
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
        iconView.activeSelfConstrains([.height(48), .width(48)])
        iconView.activeConstraints(to: contentView, directions: [.centerY, .leading(.leading, 35)])
        iconView.backgroundColor = .kokoBgGray2

        contentView.addSubview(nameLabel)
        nameLabel.activeSelfConstrains([.height(48)])
        nameLabel.activeConstraints(to: contentView, directions: [.centerY, .trailing(.trailing, -35)])
        nameLabel.activeConstraints(to: iconView, directions: [.leading(.trailing, 10)])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        iconView.image = nil
    }
    
    func configure(element: ChatElement) {
        nameLabel.text = element.name
        iconView.cornerRadius = element.elementType.cornerRadius
        element.retrieveIcon { [weak self] image in
            self?.iconView.image = image
        }
    }
}
