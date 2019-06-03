//
//  CategoryFlowLayout.swift
//  ShoppingList
//
//  Created by Jerrick Warren on 6/3/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class CategoryFlowLayout: UICollectionViewFlowLayout {
    
    let standardItemAlpha : CGFloat = 0.5
    let standardItemScale : CGFloat = 0.5
    var isSetup = false
    
    override func prepare() {
        super.prepare()
        if isSetup == false {
            setupCollectionView()
            isSetup = true
        }
    }
    
    //MARK: -  Collection View Carosel Setup
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in attributes! {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            changeLayoutAttributes(itemAttributesCopy)
            attributesCopy.append(itemAttributesCopy)
        }
        return attributesCopy
    }
    
    // Tells the view controller to ignore usual bounds
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    // PUt in var
    // Ratio for Alpha, and minimun line spacing
    func changeLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        let collectionCenter = collectionView!.frame.size.height / 2
        let offset = collectionView!.contentOffset.x + 150
        let normalizedCenter = attributes.center.x - offset + 300
        
        let maxDistance = self.itemSize.height + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance)/maxDistance
        
        let alpha = (ratio) * (1 - self.standardItemAlpha) + self.standardItemAlpha
        let scale = (1.5 * (ratio) * (1 - self.standardItemScale) + self.standardItemScale )
        
        attributes.alpha = alpha
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, (scale ), (scale ) , 1)
        attributes.zIndex = Int(alpha * 10)
    }
    
    // Snap to center
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let layoutAttributes = self.layoutAttributesForElements(in: collectionView!.bounds)
        
        let center = collectionView!.bounds.size.height / 2
        let proposedContentOffsetCenterOrigin = proposedContentOffset.x - center
        
        let closest = layoutAttributes!.sorted { abs($0.center.y - proposedContentOffsetCenterOrigin) < abs($1.center.y - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
        
        let targetContentOffset = CGPoint(x: proposedContentOffset.x, y: floor(closest.center.x - center))
        
        return targetContentOffset
    }
    
    // Declare insets
    func setupCollectionView() {
        self.collectionView!.decelerationRate = UIScrollView.DecelerationRate.fast
        
        let collectionSize = collectionView!.bounds.size
        let yInset = (collectionSize.height - self.itemSize.height) / 2
        let xInset = (collectionSize.width  - self.itemSize.width) / 2
        
        self.sectionInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
    }
    
}

