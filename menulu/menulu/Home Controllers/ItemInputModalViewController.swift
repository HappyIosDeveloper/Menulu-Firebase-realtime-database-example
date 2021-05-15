//
//  ItemInputModalViewController.swift
//  menulu
//
//  Created by Alfredo Uzumaki on 3/2/21.
//

import UIKit

protocol ItemInputModalViewControllerDelegate {
    func didAddItem(name:String, price:Int)
}

class ItemInputModalViewController: UIViewController {
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveButtonAction(_ sender: Any) {
        if let name = nameTextField.text, let priceText = priceTextField.text {
            if name.count > 1 && Int(priceText) != nil {
                let price = Int(priceText)!
                delegate?.didAddItem(name: name, price: price)
                dismissView()
            } else {
                showAlert(message: "Wrong name or price", finished: {})
            }
        } else {
            showAlert(message: "Wrong name or price", finished: {})
        }
    }
    
    var delegate: ItemInputModalViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPage()
    }
    
    func setupPage() {
        parentView.roundCorners()
        priceTextField.keyboardType = .phonePad
        nameTextField.addTarget(self, action: #selector(focusOnPriceTextField), for: .primaryActionTriggered)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func focusOnPriceTextField() {
        priceTextField.becomeFirstResponder()
    }
    
    @objc func dismissView() {
        dismiss(animated: true)
    }
}
