//
//  Shape.swift
//
//  Created by Dalton Cherry on 3/9/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public class Shape: UIView, AnimationProtocol {
    
    public var borderWidth: CGFloat = 0.0 //the width of the shape's border
    public var borderColor: UIColor? //the color of the shape's border
    public var corners = UIRectCorner.allZeros //which corners to round of the shape
    public var color: UIColor? //the color of the shape
    public var cornerRadius: CGFloat = 0.0 //the rounding of the shape
    public var shapeLayer: CAShapeLayer! //the layer that represents the view's shape layer
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //setup the properties
    func commonInit() {
        self.shapeLayer = self.layer as CAShapeLayer
        self.backgroundColor = UIColor.clearColor()
    }
    
    //implement the animations
    public func doAnimations(duration: Double, delay: Double, type: CurveType) {
        var animation = Jazz.createAnimation(duration, delay: delay, type: type, key: "path")
        animation.fromValue = shapeLayer.path
        animation.toValue = buildPath(self.frame, corners: self.corners, radius: self.cornerRadius, borWidth: self.borderWidth).CGPath
        shapeLayer.addAnimation(animation, forKey: Jazz.oneShotKey())
        
        var fill = Jazz.createAnimation(duration, delay: delay, type: type, key: "fillColor")
        fill.fromValue = shapeLayer.fillColor
        fill.toValue = self.color?.CGColor
        shapeLayer.addAnimation(fill, forKey: Jazz.oneShotKey())
        
        var bColor = Jazz.createAnimation(duration, delay: delay, type: type, key: "borderColor")
        bColor.fromValue = shapeLayer.borderColor
        bColor.toValue = self.borderColor?.CGColor
        shapeLayer.addAnimation(bColor, forKey: Jazz.oneShotKey())
        
        var bWidth = Jazz.createAnimation(duration, delay: delay, type: type, key: "borderWidth")
        bWidth.fromValue = shapeLayer.borderWidth
        bWidth.toValue = self.borderWidth
        shapeLayer.addAnimation(bWidth, forKey: Jazz.oneShotKey())
        
        var corRad = Jazz.createAnimation(duration, delay: delay, type: type, key: "cornerRadius")
        corRad.fromValue = shapeLayer.cornerRadius
        corRad.toValue = self.cornerRadius
        shapeLayer.addAnimation(corRad, forKey: Jazz.oneShotKey())
    }
    
    //finished the animation and set the shape into its final state
    public func finishAnimation(Void) {
        drawPath()
        let keys = self.shapeLayer.animationKeys()
        for key in keys {
            if let k = key as? String {
                if k.hasPrefix(Jazz.animPrefix()) {
                    self.shapeLayer.removeAnimationForKey(k)
                }
            }
        }
    }
    
    //creates the shapes path
    func buildPath(rect: CGRect, corners: UIRectCorner, radius: CGFloat, borWidth: CGFloat) -> UIBezierPath {
        var r = radius
        if r <= 0 {
            r = 0.01
        }
        let pad: CGFloat = 1
        var fr = rect
        fr.size.width = floor(rect.size.width-(pad*2))
        fr.size.height = floor(rect.size.height-(pad*2))
        fr.origin.x = pad
        fr.origin.y = pad
        var path = UIBezierPath(roundedRect: fr, byRoundingCorners: corners, cornerRadii: CGSizeMake(r, r))
        path.lineWidth = borWidth
        path.closePath()
        return path
    }
    
    //update the shape from the properties
    func drawPath() {
        shapeLayer.fillColor = self.color?.CGColor
        shapeLayer.borderWidth = self.borderWidth
        shapeLayer.borderColor = self.borderColor?.CGColor
        shapeLayer.cornerRadius = self.cornerRadius
        shapeLayer.path = buildPath(self.bounds, corners: self.corners, radius: self.cornerRadius, borWidth: self.borderWidth).CGPath
    }
    
    //draw the path
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        drawPath()
    }
    
    //set the layer of this view to be a shape
    public override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
}