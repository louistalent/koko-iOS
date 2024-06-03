//
//  UIViewController+storyboard.swift
//  kokonats
//
//  Created by yifei.zhou on 2021/09/23.
//

import UIKit

extension UIViewController {
    static func storyboardInstance() -> Self {
        let classStr = String(describing: self)
        let abbreviation = String(classStr.prefix(classStr.count - "ViewController".count))
        return UIStoryboard(name: abbreviation, bundle: Bundle.main).instantiateInitialViewController() as! Self
    }
}
