//
//  CustomTableView.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 5/15/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class CustomTableView: UITableView {

    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
