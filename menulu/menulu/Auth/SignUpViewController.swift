//
//  SignUpViewController.swift
//  SocialNetwork
//
//  Created by LzCtrl on 9/29/19.
//  Copyright © 2019 M & P Construction, Inc. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: IndicatorButton!
    @IBAction func signUpButton_Tapped(_ sender: Any) {
        register()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.roundUp()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidReOpen), name: NSNotification.Name(rawValue:  Notifications.appBecomeActive.rawValue), object: nil)
        nameField.becomeFirstResponder()
    }
    
    @objc func appDidReOpen() {
        hello()
    }
    
    func register() {
        signUpButton.startLoading()
        let auth = Auth.auth()
        auth.createUser(withEmail: emailField.text!, password: passwordField.text!) {  [self] (result, error) in
            guard error == nil else {
                signUpButton.stopLoading(withShake: true, center: signUpButton.center, comple: nil)
                return self.handleError(error: error!)
            }
            guard let user = result?.user else {
                signUpButton.stopLoading(withShake: true, center: signUpButton.center, comple: nil)
                handleError(error: fatalError("Do not know why this would happen"))
            }
            print("registered user: \(user.email ?? "")")
            updateUserDisplayName()
        }
    }
    
    func updateUserDisplayName() {
        let user = Auth.auth().currentUser
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = nameField.text!
            changeRequest.commitChanges { [self] error in
                if let _ = error {
                    print("Error while updating user display name")
                }
                UserDefaults.standard.setValue(nameField.text!, forKey: UserDefaults.names.restaurantName.rawValue)
                self.hello()
            }
        }
    }
    
    func hello() {
        guard let user = Auth.auth().currentUser else { return }
        user.reload { (error) in
            switch user.isEmailVerified {
            case true:
                print("users email is verified")
                UserDefaults.standard.set(true, forKey: UserDefaults.names.isUserSignedIn.rawValue)
                self.gotoHomeViewContoller()
            // allow to use the app
            case false:
                // email is not verified yet
                user.sendEmailVerification { [weak self] (error)in
                    guard let error = error else {
                        guard let self = self else { return }
                        print("user email verification sent")
                        self.signUpButton.stopLoading()
                        self.showAlert(message: "We send you a confirmation email, please tap on the link inside email then come back here") {
                        }
                        return
                    }
                    guard let self = self else { return }
                    self.signUpButton.stopLoading(withShake: true, center: self.signUpButton.center, comple: nil)
                    self.handleError(error: error)
                }
                print("verify it now")
            }
        }
    }
    
    func gotoHomeViewContoller() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        navigationController?.viewControllers = [vc]
    }
}
