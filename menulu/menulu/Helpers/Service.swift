//
//  Service.swift
//  SocialNetwork
//
//  Created by LzCtrl on 9/30/19.
//  Copyright © 2019 M & P Construction, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Service {
    
    static func signUpUser(email: String, password: String, name: String, onSuccess: @escaping () -> Void, onError: @escaping (_ error: Error?) -> Void) {
        
        let auth = Auth.auth()
        let settings = ActionCodeSettings()
        settings.handleCodeInApp = true
        
        auth.createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                onError(error!)
                return
            }
            let actionCodeSettings = ActionCodeSettings()
            actionCodeSettings.url = URL(string: "https://menulu.page.link")
            actionCodeSettings.handleCodeInApp = true
            actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
            actionCodeSettings.setAndroidPackageName(Bundle.main.bundleIdentifier!, installIfNotAvailable: false, minimumVersion: "1")
            auth.sendSignInLink(toEmail: email, actionCodeSettings: settings) { (error) in
                if error == nil {
                    uploadToDatabase(email: email, name: name, onSuccess: onSuccess)
                } else {
                    onError(error!)
                    return
                }
            }
        }
    }
    
    static func uploadToDatabase(email: String, name: String, onSuccess: @escaping () -> Void) {
        let ref:DatabaseReference = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        ref.child("users").child(uid!).setValue(["email" : email, "name" : name])
        onSuccess()
    }
    
    static func getUserInfo(onSuccess: @escaping () -> Void, onError: @escaping (_ error: Error?) -> Void) {
        let ref = Database.database().reference()
        let defaults = UserDefaults.standard
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not found")
            return
        }
        
        ref.child("users").child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
                let email = dictionary["email"] as! String
                let name = dictionary["name"] as! String
                defaults.set(email, forKey: "userEmailKey")
                defaults.set(name, forKey: "userNameKey")
                onSuccess()
            }
        }) { (error) in
            onError(error)
        }
    }
    
    static func createAlertController(title: String, message: String, finished: @escaping ()->()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {
                finished()
            })
        }
        alert.addAction(okAction)
        return alert
    }
}
