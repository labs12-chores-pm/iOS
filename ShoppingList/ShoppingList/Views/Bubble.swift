//
//  Bubble.swift
//  ShoppingList
//
//  Created by Nathanael Youngren on 6/3/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import UIKit

class Bubble: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        checkBubble()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkBubble()
    }
    
    func checkBubble() {
        if let isLeftBubble = isLeftBubble, isLeftBubble {
            setUpLeftBubbleShapeLayers()
        } else {
            setUpRightBubbleShapeLayers()
        }
    }
    
    func setUpLeftBubbleShapeLayers() {
        
        let edgeShapePath = UIBezierPath()
        edgeShapePath.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        edgeShapePath.addLine(to: CGPoint(x: self.bounds.minX + 5, y: self.bounds.maxY - 10))
        edgeShapePath.addQuadCurve(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY - 20), controlPoint: CGPoint(x: self.bounds.minX + 2.5, y: self.bounds.maxY - 10))
        edgeShapePath.close()
        edgeShapeLayer.path = edgeShapePath.cgPath
        edgeShapeLayer.fillColor = clearColor.cgColor
        
        layer.addSublayer(edgeShapeLayer)
        
        let bottomShapePath = UIBezierPath()
        bottomShapePath.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        bottomShapePath.addLine(to: CGPoint(x: self.bounds.minX + 10, y: self.bounds.maxY - 5))
        bottomShapePath.addQuadCurve(to: CGPoint(x: self.bounds.minX + 25, y: self.bounds.maxY), controlPoint: CGPoint(x: self.bounds.minX + 17.25, y: self.bounds.maxY))
        bottomShapePath.close()
        bottomShapeLayer.path = bottomShapePath.cgPath
        bottomShapeLayer.fillColor = clearColor.cgColor
        
        layer.addSublayer(bottomShapeLayer)
    }
    
    func setUpRightBubbleShapeLayers() {
        
        let edgeShapePath = UIBezierPath()
        edgeShapePath.move(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        edgeShapePath.addLine(to: CGPoint(x: self.bounds.maxX - 5, y: self.bounds.maxY - 10))
        edgeShapePath.addQuadCurve(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY - 20), controlPoint: CGPoint(x: self.bounds.maxX - 2.5, y: self.bounds.maxY - 10))
        edgeShapePath.close()
        edgeShapeLayer.path = edgeShapePath.cgPath
        edgeShapeLayer.fillColor = clearColor.cgColor
        
        layer.addSublayer(edgeShapeLayer)
        
        let bottomShapePath = UIBezierPath()
        bottomShapePath.move(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        bottomShapePath.addLine(to: CGPoint(x: self.bounds.maxX - 10, y: self.bounds.maxY - 5))
        bottomShapePath.addQuadCurve(to: CGPoint(x: self.bounds.maxX - 25, y: self.bounds.maxY), controlPoint: CGPoint(x: self.bounds.maxX - 17.25, y: self.bounds.maxY))
        bottomShapePath.close()
        bottomShapeLayer.path = bottomShapePath.cgPath
        bottomShapeLayer.fillColor = clearColor.cgColor
        
        layer.addSublayer(bottomShapeLayer)
    }
    
    let edgeShapeLayer = CAShapeLayer()
    let bottomShapeLayer = CAShapeLayer()
    
    var isLeftBubble: Bool?
    var clearColor: UIColor = AppearanceHelper.themeGray

}
