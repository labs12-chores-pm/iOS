//
//  IncognitoTextField.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 6/4/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class IncognitoTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
    }

    private func setAppearance() {
        borderStyle = .none
        
        let noView = UIView()
        noView.frame.size.width = 0
        
        leftView = noView
        rightView = noView
    }
}
