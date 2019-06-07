//
//  CategoryCollectionViewCell.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 6/3/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    private func setAppearance() {
        guard let category = category else { return }
        
        if let image = findCategoryImage(name: category.name) {
            categoryImage.image = image
            categoryImage.alpha = 0.5
            categoryImage.layer.borderWidth = 0
            categoryImage.layer.cornerRadius = 12
            categoryImage.clipsToBounds = true
            backgroundColor = .black
        } else {
            categoryImage.alpha = 0
            backgroundColor = AppearanceHelper.themeGray
        }
        
        layer.borderWidth = 0
        layer.cornerRadius = 12
        clipsToBounds = true
        
        categoryLabel.text = category.name
        categoryLabel.font = AppearanceHelper.boldFont(with: .body, pointSize: 16)
        categoryLabel.shadowOffset = CGSize(width: 5, height: 5)
        categoryLabel.textColor = .white
    }
    
    private func findCategoryImage(name: String) -> UIImage? {
        
        let listOfImages = [
            "backyard",
            "bathroom",
            "bedroom",
            "diningroom",
            "kidsroom",
            "kitchen",
            "livingRoom",
            "patio"
        ]
        
        let imageName = listOfImages.filter { $0.contains(name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) }.first
        
        if let imageName = imageName {
            return UIImage(named: imageName)!
        } else {
            return nil
        }
    }
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var category: Category? {
        didSet {
            setAppearance()
        }
    }
}
