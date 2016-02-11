//
//  ShapeView.swift
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
    public var frame: CGRect{ return rect}
    public var borderWidth: CGFloat{ return bezier.lineWidth}
    public var path: CGPath {return bezier.CGPath}
    public var cornerRadius: CGFloat {return radius}
    
    //frame is the frame of the shape
    //corners is which corners on the shape to round (bottom left, top right, etc)
    //radius is the radius to round the corners (e.g. 4px)
    //borderWidth is the width of border to make
    public init(frame: CGRect, corners: UIRectCorner = .AllCorners, cornerRadius: CGFloat = 0.0, borderWidth: CGFloat = 0.0 ) {
        self.rect = frame
        self.corners = corners
        var r = cornerRadius
        if r <= 0 {
            r = 0.01
        }
        radius = r
        var fr = frame
        fr.origin.x = 0
        fr.origin.y = 0
        bezier = UIBezierPath(roundedRect: fr, byRoundingCorners: corners, cornerRadii: CGSizeMake(r, r))
        bezier.lineWidth = borderWidth
        bezier.closePath()
    }
    
    //create a new ShapePath with an updated frame
    public func newFrame(frame: CGRect) -> ShapePath {
        return ShapePath(frame: frame, corners: corners, cornerRadius: cornerRadius, borderWidth: borderWidth)
    }
}


class ShapeLayer : CAShapeLayer {
    let keys = ["path": 0, "fillColor": 0, "borderColor": 0, "borderWidth": 0, "cornerRadius": 0]
    override class func needsDisplayForKey(key: String) -> Bool {
        return super.needsDisplayForKey(key)
    }
    
    override func actionForKey(event: String) -> CAAction? {

        if (keys[event] != nil) {
            if let action = super.actionForKey("backgroundColor") as? CABasicAnimation {
                let animation = CABasicAnimation(keyPath: event)
                animation.fromValue = valueForKey(event)
                // Copy values from existing action
                animation.autoreverses = action.autoreverses
                animation.beginTime = CACurrentMediaTime() + action.beginTime
                animation.delegate = action.delegate
                animation.duration = action.duration
                animation.fillMode = action.fillMode
                animation.repeatCount = action.repeatCount
                animation.repeatDuration = action.repeatDuration
                animation.speed = action.speed
                animation.timingFunction = action.timingFunction
                animation.timeOffset = action.timeOffset
                return animation
            }
        }
        return super.actionForKey(event)
    }
}

public class ShapeView: UIView {
    override public var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    //layout is the values the create the layer's path
    public var layout: ShapePath {
        didSet {
            frame = layout.frame
        }
        
    }
    //the color of the shape's border
    public var borderColor: UIColor? {
        didSet {
            drawPath()
        }
    }
    
    //the color of the shape
    public var color: UIColor? {
        didSet {
            drawPath()
        }
    }
    
    //do the layout updates when the frame updates
    override public var frame: CGRect {
        didSet {
            if !CGRectEqualToRect(frame, layout.rect) {
                layout = layout.newFrame(frame)
            } else {
                drawPath()
            }
        }
    }
    
    override public init(frame: CGRect) {
        layout = ShapePath(frame: frame, cornerRadius: 0, borderWidth: 0)
        super.init(frame: frame)
        commonInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        layout = ShapePath(frame: CGRectZero, cornerRadius: 0, borderWidth: 0)
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
        backgroundColor = UIColor.clearColor()
        drawPath()
    }
    
    //update the shape from the properties
    func drawPath() {
        layer.fillColor = color?.CGColor
        layer.borderColor = borderColor?.CGColor
        layer.borderWidth = layout.borderWidth
        layer.cornerRadius = layout.cornerRadius
        layer.path = layout.path
    }
    
    //set the layer of this view to be a shape
    public override class func layerClass() -> AnyClass {
        return ShapeLayer.self
    }
}