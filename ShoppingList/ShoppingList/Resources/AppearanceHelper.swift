//
//  AppearanceHelper.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/22/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class AppearanceHelper {
    
    static let pink = UIColor(red: 223/255, green: 78/255, blue: 144/255, alpha: 1)
    
    static func styleFont(with textStyle: UIFont.TextStyle, pointSize: CGFloat) -> UIFont {
        let font = UIFont(name: "Nunito", size: pointSize)!
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
    
    static func boldFont(with textStyle: UIFont.TextStyle, pointSize: CGFloat) -> UIFont {
        let font = UIFont(name: "Nunito-Bold", size: pointSize)!
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
