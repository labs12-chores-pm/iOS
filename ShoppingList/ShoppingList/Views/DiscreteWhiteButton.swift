//
//  DiscreteWhiteButton.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/31/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class DiscreteWhiteButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        titleLabel?.font = AppearanceHelper.boldFont(with: .body, pointSize: 14)
        tintColor = .gray
    }
}
