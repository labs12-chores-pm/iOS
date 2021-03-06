//
//  NavigationViewController.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/23/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        
        let logo = UIImage(named: "white-logo")
        let image = UIImageView(image: logo)
        
        navigationBar.addSubview(image)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.topAnchor.constraint(equalTo: self.navigationBar.topAnchor, constant: 8).isActive = true
        image.bottomAnchor.constraint(equalTo: self.navigationBar.bottomAnchor, constant: -8).isActive = true
        image.centerXAnchor.constraint(equalTo: self.navigationBar.centerXAnchor, constant: 0).isActive = true
        image.widthAnchor.constraint(equalTo: image.heightAnchor, multiplier: 1).isActive = true
        
        navigationBar.barTintColor = AppearanceHelper.midOrange
        
        navigationBar.backgroundColor = .white
        
        navigationBar.isTranslucent = false
        
        navigationBar.tintColor = .white
        navigationBar.barStyle = .default
        
        AppearanceHelper.setNavigationStyle()
    }
}
