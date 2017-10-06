//
//  ShapeView.swift
//
//  Created by Dalton Cherry on 3/9/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public struct ShapePath {
    public let bezier: UIBezierPath
    public let radius: CGFloat
    public let rect: CGRect
    public let corners: UIRectCorner
    public var frame: CGRect{ return rect}
    public var borderWidth: CGFloat{ return bezier.lineWidth}
    public var path: CGPath {return bezier.cgPath}
    public var cornerRadius: CGFloat {return radius}
    
    //frame is the frame of the shape
    //corners is which corners on the shape to round (bottom left, top right, etc)
    //radius is the radius to round the corners (e.g. 4px)
    //borderWidth is the width of border to make
    public init(frame: CGRect, corners: UIRectCorner = .allCorners, cornerRadius: CGFloat = 0.0, borderWidth: CGFloat = 0.0 ) {
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
        bezier = UIBezierPath(roundedRect: fr, byRoundingCorners: corners, cornerRadii: CGSize(width: r, height: r))
        bezier.lineWidth = borderWidth
        bezier.close()
    }
    
    //create a new ShapePath with an updated frame
    public func newFrame(_ frame: CGRect) -> ShapePath {
        return ShapePath(frame: frame, corners: corners, cornerRadius: cornerRadius, borderWidth: borderWidth)
    }
}


open class ShapeLayer : CAShapeLayer {
    var keys = ["path": 0, "fillColor": 0, "borderColor": 0, "borderWidth": 0, "cornerRadius": 0]
    
    override open class func needsDisplay(forKey key: String) -> Bool {
        return super.needsDisplay(forKey: key)
    }
    
    override open func action(forKey event: String) -> CAAction? {
        
        if (keys[event] != nil) {
            if let action = super.action(forKey: "backgroundColor") as? CABasicAnimation {
                let animation = CABasicAnimation(keyPath: event)
                animation.fromValue = value(forKey: event)
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
        return super.action(forKey: event)
    }
}

open class ShapeView: UIView {
    override open var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    //layout is the values the create the layer's path
    open var layout: ShapePath {
        didSet {
            frame = layout.frame
        }
        
    }
    //the color of the shape's border
    open var borderColor: UIColor? {
        didSet {
            drawPath()
        }
    }
    
    //the color of the shape
    open var color: UIColor? {
        didSet {
            drawPath()
        }
    }
    
    //do the layout updates when the frame updates
    override open var frame: CGRect {
        didSet {
            if !frame.equalTo(layout.rect) {
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
        layout = ShapePath(frame: CGRect.zero, cornerRadius: 0, borderWidth: 0)
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
        backgroundColor = UIColor.clear
        drawPath()
    }
    
    //update the shape from the properties
    open func drawPath() {
        layer.fillColor = color?.cgColor
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = layout.borderWidth
        layer.cornerRadius = layout.cornerRadius
        layer.path = layout.path
    }
    
    //set the layer of this view to be a shape
    open override class var layerClass : AnyClass {
        return ShapeLayer.self
    }
}
