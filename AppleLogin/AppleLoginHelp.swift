//
//  AppleLoginHelp.swift
//  AppleLogin
//
//  Created by imac on 2019/9/6.
//  Copyright © 2019 代亚洲. All rights reserved.
//

import Foundation
import AuthenticationServices

class AppleLoginHelp: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public var didCompleteWithAuthorizationCallback:((_ nickName: String, _ userIdentifier: String, _ email: String) -> ())?
    
    static let sharedInstance = AppleLoginHelp()
        
    @available(iOS 13.0, *)
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email ?? ""
            
            do {
                try CRAppleKeychainAuthStore(service: AppInfo.BundleIdentifier, account: "user_Identifier").saveItem(userIdentifier)
            } catch {
                print("无法将用户标识符保存到钥匙串")
            }
            var nickName: String = ""
            if fullName != nil {
                nickName = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            }
            didCompleteWithAuthorizationCallback?(nickName,userIdentifier,email)
        }
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("appleLogin error")
        print(error.localizedDescription)
    }
    
    //MARK: ASAuthorizationControllerPresentationContextProviding
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.visibleViewController?.view.window ?? ASPresentationAnchor()
    }
}
