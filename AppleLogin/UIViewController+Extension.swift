//
//  UIViewController+Extension.swift
//  AppleLogin
//
//  Created by imac on 2019/9/6.
//  Copyright © 2019 代亚洲. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return UIViewController.visibleViewController(from: navigationController.visibleViewController)
        } else if let tabBarController = viewController as? UITabBarController {
            return UIViewController.visibleViewController(from: tabBarController.selectedViewController)
        } else {
            if let presentedViewController = viewController?.presentedViewController {
                return UIViewController.visibleViewController(from: presentedViewController)
            } else {
                return viewController
            }
        }
    }
}
