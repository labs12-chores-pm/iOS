//
//  UIViewController+Alert.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 5/22/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func displayMsg(title : String?, msg : String, numberOfButtons: Int = 1, completion: @escaping (Bool?) -> Void = { _ in } ) {

        let ac = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
                    
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            completion(true)
        }
                    
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            completion(false)
        })
        
        if numberOfButtons > 1 {
            ac.addAction(cancelAction)
        }
        ac.addAction(confirmAction)
                    
        DispatchQueue.main.async {
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func getActivityView() -> UIActivityIndicatorView {
        let activityView = UIActivityIndicatorView()
        activityView.style = .gray
        
        let xPosition = (self.view.frame.width / 2) - 15
        let yPosition = (self.view.frame.height / 2) - 15
        
        activityView.frame = CGRect(x: xPosition, y: yPosition, width: 30, height: 30)
        activityView.hidesWhenStopped = true
        
        self.view.addSubview(activityView)
        
        return activityView
    }
}
