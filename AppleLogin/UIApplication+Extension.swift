//
//  UIApplication+Extension.swift
//  AppleLogin
//
//  Created by imac on 2019/9/6.
//  Copyright © 2019 代亚洲. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    static var visibleTopWindow: UIWindow? {
        let count = UIApplication.shared.windows.count - 1
        var visibleWindow: UIWindow? = nil
        for i in 0...count {
            if !UIApplication.shared.windows[count - i].isHidden {
                visibleWindow = UIApplication.shared.windows[count - i]
                break
            }
        }
        return visibleWindow
    }
    
}

extension UIApplication {
    static var visibleViewController: UIViewController? {
        return UIViewController.visibleViewController(from: UIApplication.shared.delegate?.window??.rootViewController)
    }
}
