//
//  ViewController.swift
//  AppleLogin
//
//  Created by imac on 2019/9/6.
//  Copyright © 2019 代亚洲. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    ///自定义
    let button: UIButton = {
        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 200, height: 40))
        button.setTitle("apple Login", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(onclickAuthorizationButton), for: .touchUpInside)
        return button
    }()
    /*系统的样式 可以自己修改
     @available(iOS 13.0, *)
     public enum ButtonType : Int {
         case signIn
         case `continue`
         public static var `default`: ASAuthorizationAppleIDButton.ButtonType { get }
     }
     @available(iOS 13.0, *)
     public enum Style : Int {
         case white
         case whiteOutline
         case black
     }
    */
    let authorizationButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(onclickAuthorizationButton), for: .touchUpInside)
        button.frame = CGRect(x: 100, y: 400, width: 200, height: 40)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        self.view.addSubview(authorizationButton)
        AppleLoginHelp.sharedInstance.didCompleteWithAuthorizationCallback = {[weak self] (nickName, userIdentifier, email) in
            print("""
                    nickName: \(nickName)
                    email: \(userIdentifier)
                    userIdentifier: \(email)
                    """)
        }
    }

    @objc private func onclickAuthorizationButton() {
        if #available(iOS 13.0, *) {
            AppleLoginHelp.sharedInstance.handleAuthorizationAppleIDButtonPress()
        } else {

        }
    }
}

