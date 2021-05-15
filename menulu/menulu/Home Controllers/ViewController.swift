//
//  ViewController.swift
//  menulu
//
//  Created by Alfredo Uzumaki on 2/19/21.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    @IBOutlet weak var welcomeInLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBAction func logOutButton_Tapped(_ sender: Any) {
        logoutAction()
    }
    @IBAction func addRowButtonAction(_ sender: Any) {
        openAddItemController()
    }
    
    var user: User?
    var ref = Database.database().reference()
    var items = [[String: Int]]()
    var restaurantName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantName = UserDefaults.standard.string(forKey: UserDefaults.names.restaurantName.rawValue) ?? ""
        if restaurantName.isEmpty {
            logoutAction()
        } else {
            hello()
        }
    }
    
    func setupPageForLoggedInUser() {
        welcomeInLabel.text = "Welcome " + (user?.displayName ?? "")
        fetchData()
    }

    func openAddItemController() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ItemInputModalViewController") as! ItemInputModalViewController
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func gotoWelcomeViewController() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        navigationController?.viewControllers = [vc]
    }
}

// MARK: - TableView Functions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = items[indexPath.row]
        cell.textLabel?.text = "\(item.keys.first ?? "?")    \(item.values.first?.description ?? "?")"
        return cell
    }
}

// MARK: - AddItem Delegate Functions
extension ViewController: ItemInputModalViewControllerDelegate {
    
    func didAddItem(name: String, price: Int) {
        addItem(name: name, price: price)
    }
}

// MARK: - API Functions
extension ViewController {
    
    func hello() {
        guard let user = Auth.auth().currentUser else { // sign in or sign up
            gotoWelcomeViewController()
            return
        }
        user.reload { (error) in
            switch user.isEmailVerified {
            case true:
                print("users email is verified")
                self.user = user
                self.setupPageForLoggedInUser()
            case false:
                // email is not verified yet
                user.sendEmailVerification { (error) in
                    guard let error = error else {
                        print("user email verification sent")
                        self.showAlert(message: "We send you a confirmation email, please tap on the link inside email then re open the app."){}
                        return
                    }
                    self.handleError(error: error)
                }
                print("verify it now")
            }
        }
    }
    
    func signin(auth: Auth, email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                return self.handleError(error: error!)
            }
            guard let user = result?.user else{
                fatalError("Not user do not know what went wrong")
            }
            print("Signed in user: \(user.email)")
        }
    }
    
    func register(auth: Auth, email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                return self.handleError(error: error!)
            }
            guard let user = result?.user else {
                fatalError("Do not know why this would happen")
            }
            print("registered user: \(user.email)")
        }
    }
    
    func addItem(name: String, price: Int) {
        indicator.startAnimating()
        let item = [name: price]
        items.append(item)
        ref.setValue([restaurantName: items]) { [self] (err, dbRefrence) in
            tableView.reloadData()
            indicator.stopAnimating()
        }
    }
    
    func fetchData() {
        ref.child(restaurantName).observeSingleEvent(of: .value, with: { [self] (snapshot) in
            indicator.stopAnimating()
            if let values1 = snapshot.value {
                guard let values2 = values1 as? [Any] else {
                    print("error 1")
                    return
                }
                guard let values3 = values2 as? [[String: Any]] else {
                    print("error 2")
                    return
                }
                for value in values3 {
                    for (key, value) in value {
                        print("key: \(key) | value: \(value)")
                        if let item = [key: value] as? [String: Int] {
                            items.append(item)
                        }
                    }
                }
                tableView.reloadData()
            }
        })
    }
    
    func logoutAction() {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            UserDefaults.standard.set(nil, forKey: UserDefaults.names.restaurantName.rawValue)
            UserDefaults.standard.set(false, forKey: UserDefaults.names.isUserSignedIn.rawValue)
            navigationItem.rightBarButtonItem = nil
            let vc = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            navigationController?.viewControllers = [vc]
        } catch let signOutError {
            self.present(Service.createAlertController(title: "Error", message: signOutError.localizedDescription, finished: {}), animated: true, completion: nil)
        }
    }
}
