//
//  UIViewController+Alert.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/22/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

extension UIViewController {
    
func displayMsg(title : String?,
                msg : String,
                style : UIAlertController.Style = .alert,
                completion: @escaping (Bool?) -> Void = { _ in } )
                {
    

        let ac = UIAlertController.init(title: title,
                                        message: msg, preferredStyle: style)
                    
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            completion(true)
        }
                    
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default,
                                         handler: { (_) in
            completion(false)
        })
                    
        ac.addAction(confirmAction)
        ac.addAction(cancelAction)
                    
        DispatchQueue.main.async {
            self.present(ac, animated: true, completion: nil)
        }
    }
}
