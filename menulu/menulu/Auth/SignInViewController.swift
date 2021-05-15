//
//  SignInViewController.swift
//  SocialNetwork
//
//  Created by LzCtrl on 9/29/19.
//  Copyright © 2019 M & P Construction, Inc. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: IndicatorButton!
    @IBAction func signInButton_Tapped(_ sender: Any) {
        signin()
    }
    @IBAction func forgotPassButton_Tapped(_ sender: Any) {
        self.performSegue(withIdentifier: "forgotPassSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.roundUp()
        emailField.becomeFirstResponder()
    }
    
    func signin() {
        signInButton.startLoading()
        let auth = Auth.auth()
        auth.signIn(withEmail: emailField.text!, password: passwordField.text!) { [self] (result, error) in
            signInButton.stopLoading()
            guard error == nil else {
                return handleError(error: error!)
            }
            guard let user = result?.user else {
                handleError(error: fatalError("Not user do not know what went wrong"))
            }
            if user.isEmailVerified {
                UserDefaults.standard.set(true, forKey: UserDefaults.names.isUserSignedIn.rawValue)
                DispatchQueue.main.async {
                    self.gotoHomeViewContoller()
                }
            } else {
                showAlert(message: "Please verify your email first!") {}
            }
        }
    }
    
    func gotoHomeViewContoller() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        navigationController?.viewControllers = [vc]
    }
}
