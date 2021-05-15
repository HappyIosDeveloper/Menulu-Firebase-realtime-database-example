//
//  WelcomeViewController.swift
//  SocialNetwork
//
//  Created by LzCtrl on 9/29/19.
//  Copyright © 2019 M & P Construction, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signInButton_Tapped(_ sender: Any) {
        self.performSegue(withIdentifier: "signInSegue", sender: nil)
    }
    @IBAction func signUpButton_Tapped(_ sender: Any) {
        self.performSegue(withIdentifier: "signUpSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Menulu"
        signInButton.roundUp()
        signUpButton.roundUp()
        hello()
    }
    
    func hello() {
        guard let user = Auth.auth().currentUser else { return }
        user.reload { (error) in
            switch user.isEmailVerified {
            case true:
                print("users email is verified")
                self.gotoHomeViewContoller() // allow to use the app
            case false:
                // email is not verified yet
                user.sendEmailVerification { (error) in
                    guard let error = error else {
                        return print("user email verification sent")
                    }
                    if !error.localizedDescription.contains("deleted") {
                        self.handleError(error: error)
                    }
                }
            }
        }
    }
    
    func gotoHomeViewContoller() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        navigationController?.viewControllers = [vc]
    }
}
