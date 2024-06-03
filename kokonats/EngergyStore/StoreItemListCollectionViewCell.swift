////  StoreItemListCollectionViewCell.swift
//  kokonats
//
//  Created by sean on 2022/03/19.
//  
//

import Foundation
import UIKit

final class StoreItemListCollectionViewCell: UICollectionViewCell {
    private var iconImage: UIImageView!
    private var priceLabel: UILabel!
    private var kokoIcon: UIImageView!
    private var purchasedLabel: UILabel!
    private var priceContainerView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImage.image = nil
    }
    
    private func prepareLayout() {
        layer.cornerRadius = 10
        contentView.clipsToBounds = true
        backgroundColor = .lightBgColor
        dropShadow(cornerRadius: 5)
        
        iconImage = UIImageView()
        iconImage.backgroundColor = .clear
        contentView.addSubview(iconImage)
        iconImage.activeConstraints(directions: [.top(.top, 10), .leading(), .centerX])
        iconImage.contentMode = .scaleAspectFit
        iconImage.activeSelfConstrains([.height(138)])

        priceContainerView = UIView()
        priceContainerView.backgroundColor = .clear
        contentView.addSubview(priceContainerView)
        priceContainerView.activeConstraints(directions: [.centerX, .bottom(.bottom, -10)])
        priceContainerView.activeSelfConstrains([.height(15)])

        priceLabel = UILabel.formatedLabel(size: 15, text: "", type: .black, textAlignment: .center)
        priceContainerView.addSubview(priceLabel)
        priceLabel.activeConstraints(directions: [.trailing(), .top(), .bottom()])

        let kokoIcon = UIImageView.fromImage(name: "dollar_icon")
        priceContainerView.addSubview(kokoIcon)
        kokoIcon.activeSelfConstrains([.width(15), .height(15)])
        kokoIcon.activeConstraints(directions: [.leading(.leading), .top(), .bottom()])
        kokoIcon.activeConstraints(to: priceLabel, directions: [.trailing(.leading, -4)])

        purchasedLabel = UILabel.formatedLabel(size: 10, text: "shop_purchased_label".localized, type: .black, textAlignment: .center)
        purchasedLabel.textColor = .purchasedLabelColor
        contentView.addSubview(purchasedLabel)
        purchasedLabel.activeConstraints(directions: [.centerX, .bottom()])
        purchasedLabel.activeSelfConstrains([.height(15)])
        purchasedLabel.isHidden = true
    }

    func update(price: Int, isPurchased: Bool) {
        priceContainerView.isHidden = isPurchased
        purchasedLabel.isHidden = !isPurchased
        iconImage.alpha = isPurchased ? 0.5 : 1
        priceLabel.text = String(price)
    }

    func updateIcon(with image: UIImage) {
        iconImage.image = image
    }
}
