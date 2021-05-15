//
//  File.swift
//  menulu
//
//  Created by Alfredo Uzumaki on 2/25/21.
//

import UIKit
import Firebase

extension UIViewController {
    
    func handleError(error: Error, isError:Bool = true) {
        DispatchQueue.main.async {
            let errorAuthStatus = AuthErrorCode.init(rawValue: error._code)!
            var alert = UIAlertController()
            if isError {
                switch errorAuthStatus {
                case .wrongPassword:
                    alert = Service.createAlertController(title: "Error", message: "Wrong Password or invalid Enmail!"){}
                case .invalidEmail:
                    alert = Service.createAlertController(title: "Error", message: "Wrong Password or invalid Enmail!"){}
                case .operationNotAllowed:
                    alert = Service.createAlertController(title: "Error", message: "Operation not allowed!"){}
                case .userDisabled:
                    alert = Service.createAlertController(title: "Error", message: "User is Desabled!"){}
                case .userNotFound:
                    alert = Service.createAlertController(title: "Error", message: "User Not Found!"){}
                case .tooManyRequests:
                    print("tooManyRequests")
                    break
                //                alert = Service.createAlertController(title: "Error", message: "Please slow down!, too many request!"){}
                case .emailAlreadyInUse:
                    alert = Service.createAlertController(title: "Error", message: "Email is already in use!"){}
                case .internalError:
                    alert = Service.createAlertController(title: "Error", message: "Connection Error!"){}
                default:
                    alert = Service.createAlertController(title: "Error", message: "Weird Error!"){}
                }
            } else {
                alert = Service.createAlertController(title: "Attention", message: error.localizedDescription){}
            }
            if alert.title != nil {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(title:String = "Attention", message:String, finished: @escaping ()->()) {
        DispatchQueue.main.async {
            let alert = Service.createAlertController(title: title, message: message) {
                finished()
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIView {
    
    func roundUp() {
        self.clipsToBounds = true
        self.layer.cornerRadius = bounds.height / 2
    }
    
    func roundCorners() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }
}

extension UserDefaults {
    
    enum names: String {
        case restaurantName = "restaurantName"
        case isUserSignedIn = "isUserSignedIn"
    }
}
