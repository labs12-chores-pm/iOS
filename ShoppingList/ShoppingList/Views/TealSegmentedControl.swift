//
//  TealSegmentedControl.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 6/1/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit
    
class TealSegmentedControl: UISegmentedControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSegmentedControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSegmentedControl()
    }
    
    private func setUpSegmentedControl() {
        tintColor = AppearanceHelper.teal
        let font = AppearanceHelper.styleFont(with: .body, pointSize: 14)
        setTitleTextAttributes([.font : font], for: .normal)
    }
}
