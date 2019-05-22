//
//  AlertExtension.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/22/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

extension UIViewController {
func displayMsg(title : String?, msg : String,
                style: UIAlertController.Style = .alert,
                cancelKey : String? = nil) {
    if cancelKey != nil,
        UserDefaults.standard.bool(forKey: cancelKey!) == true {
        return
    }
    
    let ac = UIAlertController.init(title: title,
                                    message: msg, preferredStyle: style)
    ac.addAction(UIAlertAction.init(title: "Confirm",
                                    style: .default, handler: nil))
    
    if cancelKey != nil {
        ac.addAction(UIAlertAction.init(title: "Cancel",
                                        style: .default, handler: { (aa) in
                                            UserDefaults.standard.set(true, forKey: cancelKey!)
                                            UserDefaults.standard.synchronize()
        }))
    }
    DispatchQueue.main.async {
        self.present(ac, animated: true, completion: nil)
    }
}
}
