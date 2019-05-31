//
//  MonkeyButton.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/23/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class MonkeyButton: UIButton {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = AppearanceHelper.yellow
        titleLabel?.font = AppearanceHelper.boldFont(with: .body, pointSize: 16)
        layer.cornerRadius  = frame.size.height / 2
        tintColor = .brown
    }
    
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 8, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 8, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}
