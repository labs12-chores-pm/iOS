//
//  AddCategoryViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/17/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNameField.delegate = self
        viewTapGestureRecognizer.delegate = self
        setGestureRecogizer()
    }
    
    @IBAction func createCategoryButtonWasTapped(_ sender: UIButton) {
        guard let categoryController = categoryController, let user = currentUser else { fatalError() }
        guard let name = categoryNameField.text else {
            createCategoryButton.shake()
            displayMsg(title: "Missing field", msg: "Please add a category name")
            return
        }
        
        categoryController.createCategory(householdId: user.currentHouseholdId, name: name)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var categoryNameField: UITextField!
    @IBOutlet weak var createCategoryButton: MonkeyButton!
    
    var categoryController: CategoryController?
    var currentUser: User?
    
    var viewTapGestureRecognizer = UITapGestureRecognizer()
    var textFieldBeingEdited: UITextField?
}

extension AddCategoryViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBeingEdited = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldBeingEdited = nil
        textField.resignFirstResponder()
        return true
    }
}

extension AddCategoryViewController: UIGestureRecognizerDelegate {
    
    private func setGestureRecogizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        viewTapGestureRecognizer = tapRecognizer
        view.addGestureRecognizer(viewTapGestureRecognizer)
    }
    
    @objc func viewWasTapped() {
        if let textField = textFieldBeingEdited {
            textField.resignFirstResponder()
            textFieldBeingEdited = nil
        }
    }
}
