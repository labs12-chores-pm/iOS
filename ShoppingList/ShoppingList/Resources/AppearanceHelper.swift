//
//  AppearanceHelper.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/22/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class AppearanceHelper {
    
    static let pinkThemeColor = #colorLiteral(red: 0.9125601649, green: 0.1181406602, blue: 0.3897231221, alpha: 1)
    static let teal = UIColor(red: 106/255, green: 204/255, blue: 198/255, alpha: 1)
    static let lightYellow = UIColor(red: 255/255, green: 218/255, blue: 158/255, alpha: 1)
    static let babyBlue = UIColor(red: 222/255, green: 248/255, blue: 255/255, alpha: 1)
    static let yellowBrown = UIColor(red: 204/255, green: 186/255, blue: 106/255, alpha: 1)
    
    static let yellow = #colorLiteral(red: 0.9928019643, green: 0.7650975585, blue: 0.1207756624, alpha: 1)
    static let lightOrange = #colorLiteral(red: 0.9405652881, green: 0.663567245, blue: 0.1158531085, alpha: 1)
    static let midOrange = #colorLiteral(red: 0.9414839149, green: 0.5269313455, blue: 0.1456429958, alpha: 1)
    static let darkOrange = #colorLiteral(red: 0.943921864, green: 0.4410427809, blue: 0.1553348303, alpha: 1)
    
    static func setNavigationStyle() {
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: styleFont(with: .body, pointSize: 16),
            .foregroundColor: UIColor.brown,
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(buttonAttributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(buttonAttributes, for: .selected)
        UIBarButtonItem.appearance().setTitleTextAttributes(buttonAttributes, for: .highlighted)
        UINavigationBar.appearance().tintColor = darkOrange
    }
    
    static func styleFont(with textStyle: UIFont.TextStyle, pointSize: CGFloat) -> UIFont {
        let font = UIFont(name: "Nunito", size: pointSize)!
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
    
    static func boldFont(with textStyle: UIFont.TextStyle, pointSize: CGFloat) -> UIFont {
        let font = UIFont(name: "Nunito-Bold", size: pointSize)!
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
