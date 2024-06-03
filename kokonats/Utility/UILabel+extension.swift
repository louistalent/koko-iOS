////  UILabel+extension.swift
//  kokonats
//
//  Created by sean on 2021/11/27.
//  
//

import Foundation
import UIKit

extension UILabel {

    static func formatedLabel(size: CGFloat? = nil, text: String? = nil, type: UIFont.kokoFontType = .regular, textAlignment: NSTextAlignment = .center) -> UILabel {
        let label = UILabel()
        guard let customFont = UIFont(name: type.rawValue, size: size ?? UIFont.labelFontSize) else {
            fatalError("""
                Failed to load the "\(type.rawValue)" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        label.font = customFont
        label.textColor = .white
        label.textAlignment = textAlignment
        label.baselineAdjustment = .alignCenters
        label.numberOfLines = 1
        text.flatMap { label.text = $0 }
        return label
    }
}

extension UIFont {
    enum kokoFontType: String {
        case black = "NotoSansJP-Black"
        case bold = "NotoSansJP-Bold"
        case medium = "NotoSansJP-Medium"
        case regular = "NotoSansJP-Regular"
    }

    static func getKokoFont(type: kokoFontType = .regular, size: CGFloat? = nil) -> UIFont {
        guard let customFont = UIFont(name: type.rawValue, size: size ?? UIFont.labelFontSize) else {
            fatalError("""
                Failed to load the "\(type.rawValue)" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        return customFont
    }
}
