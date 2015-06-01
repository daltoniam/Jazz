//
//  Shape.swift
//
//  Created by Dalton Cherry on 3/9/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public class ShapePath {
    var bezier: UIBezierPath
    var radius: CGFloat
    var rect: CGRect
    var corners: UIRectCorner
    public var frame: CGRect{ return self.rect}
    public var borderWidth: CGFloat{ return self.bezier.lineWidth}
    public var path: CGPath {return self.bezier.CGPath}
    public var cornerRadius: CGFloat {return self.radius}
    
    //frame is the frame of the shape
    //corners is which corners on the shape to round (bottom left, top right, etc)
    //radius is the radius to round the corners (e.g. 4px)
    //borderWidth is the width of border to make
    public init(frame: CGRect, corners: UIRectCorner = UIRectCorner.allZeros, cornerRadius: CGFloat = 0.0, borderWidth: CGFloat = 0.0 ) {
        self.rect = frame
        self.corners = corners
        var r = cornerRadius
        if r <= 0 {
            r = 0.01
        }
        radius = r
        let pad: CGFloat = 1
        var fr = frame
        fr.size.width = floor(frame.size.width-(pad*2))
        fr.size.height = floor(frame.size.height-(pad*2))
        fr.origin.x = pad
        fr.origin.y = pad
        bezier = UIBezierPath(roundedRect: fr, byRoundingCorners: corners, cornerRadii: CGSizeMake(r, r))
        bezier.lineWidth = borderWidth
        bezier.closePath()
    }
    
    //create a new ShapePath with an updated frame
    public func newFrame(frame: CGRect) -> ShapePath {
        return ShapePath(frame: frame, corners: self.corners, cornerRadius: self.cornerRadius, borderWidth: self.borderWidth)
    }
    
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
}

public class Shape: UIView {
    public var shapeLayer: CAShapeLayer! //the layer that represents the view's shape layer
    
    //layout is the values the create the layer's path
    public var layout: ShapePath {
        didSet {
            self.frame = self.layout.frame
        }
        
    }
    //the color of the shape's border
    public var borderColor: UIColor? {
        didSet {
            doBorderColor()
        }
    }
    
    //the color of the shape
    public var color: UIColor? {
        didSet {
            doFillColor()
        }
    }
    
    //do the layout updates when the frame updates
    override public var frame: CGRect {
        didSet {
            if !CGRectEqualToRect(frame, self.layout.rect) {
                self.layout = self.layout.newFrame(frame)
            } else {
                doLayoutAnimation()
            }
        }
    }
    
    override public init(frame: CGRect) {
        self.layout = ShapePath(frame: frame, corners: UIRectCorner.allZeros, cornerRadius: 0, borderWidth: 0)
        super.init(frame: frame)
        commonInit()
    }
    required public init(coder aDecoder: NSCoder) {
        self.layout = ShapePath(frame: CGRectZero, corners: UIRectCorner.allZeros, cornerRadius: 0, borderWidth: 0)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public init(layout: ShapePath) {
        self.layout = layout
        super.init(frame: self.layout.frame)
        commonInit()
    }
    
    //setup the properties
    func commonInit() {
        self.shapeLayer = self.layer as! CAShapeLayer
        self.backgroundColor = UIColor.clearColor()
        drawPath()
    }
    
    //do that frame layout animation!
    func doLayoutAnimation() {
        if let layer = shapeLayer {
            var animation = Jazz.createAnimation(key: "path")
            animation.fromValue = layer.path
            animation.toValue = layout.path
            layer.addAnimation(animation, forKey: Jazz.oneShotKey())
            layer.path = layout.path
            
            var bAnimation = Jazz.createAnimation(key: "borderWidth")
            bAnimation.fromValue = shapeLayer.borderWidth
            bAnimation.toValue = layout.borderWidth
            layer.addAnimation(bAnimation, forKey: Jazz.oneShotKey())
            layer.borderWidth = layout.borderWidth
        }
    }
    
    //do that fill color
    func doFillColor() {
        if let layer = shapeLayer {
            var animation = Jazz.createAnimation(key: "fillColor")
            animation.fromValue = layer.fillColor
            animation.toValue = color?.CGColor
            layer.addAnimation(animation, forKey: Jazz.oneShotKey())
            layer.fillColor = color?.CGColor
        }
    }
    
    //do the border color
    func doBorderColor() {
        if let layer = shapeLayer {
            let dur = CATransaction.animationDuration()
            var animation = Jazz.createAnimation(key: "borderColor")
            animation.fromValue = layer.borderColor
            animation.toValue = borderColor?.CGColor
            layer.addAnimation(animation, forKey: Jazz.oneShotKey())
            layer.borderColor = borderColor?.CGColor
        }
    }
    
    //the animations have finished
    override public func animationDidStop(anim: CAAnimation!, finished: Bool) {
    }
    
    //update the shape from the properties
    func drawPath() {
        shapeLayer.fillColor = self.color?.CGColor
        shapeLayer.borderColor = self.borderColor?.CGColor
        shapeLayer.borderWidth = self.layout.borderWidth
        shapeLayer.cornerRadius = self.layout.cornerRadius
        shapeLayer.path = self.layout.path
    }
    
    //set the layer of this view to be a shape
    public override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
}