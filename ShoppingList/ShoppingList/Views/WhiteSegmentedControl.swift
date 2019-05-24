//
//  WhiteSegmentedControl.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/23/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class WhiteSegmentedControl: UISegmentedControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSegmentedControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSegmentedControl()
    }
    
    private func setUpSegmentedControl() {
        tintColor = AppearanceHelper.babyBlue
    }
}
