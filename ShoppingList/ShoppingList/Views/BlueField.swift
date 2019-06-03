//
//  BlueField.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/23/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class BlueField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpField()
    }
    
    private func setUpField() {
        backgroundColor = AppearanceHelper.themeGray
        layer.cornerRadius = frame.size.height / 2
        font = AppearanceHelper.styleFont(with: .body, pointSize: 14)
    }

}
