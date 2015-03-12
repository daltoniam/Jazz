//
//  Button.swift
//
//  Created by Dalton Cherry on 3/11/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public class Button: Shape {
    private var highlighted = false
    public var isHightlighted: Bool {return highlighted}
    public var highlightColor: UIColor?
    public var textLabel: UILabel = UILabel()
    public var enabled: Bool = true {
        didSet {
           textLabel.enabled = enabled
        }
    }
    public var ripple = false
    private var tapHandler: ((Void) -> Void)?
    private var rippleLayer: CAShapeLayer?
    
    //standard view init method
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //standard view init method
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //setup the properties
    override func commonInit() {
        super.commonInit()
        self.shapeLayer.masksToBounds = true
        self.autoresizesSubviews = true
        self.setTranslatesAutoresizingMaskIntoConstraints(true)
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.textAlignment = .Center
        textLabel.contentMode = .Center
        textLabel.autoresizingMask = .FlexibleWidth | .FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin
        self.addSubview(textLabel)
        let tap = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    //handle when the button is tapped
    public func didTap(handler: ((Void) -> Void)) {
        tapHandler = handler
    }
    
    public override func doAnimations(duration: Double, delay: Double, type: CurveType) {
        super.doAnimations(duration, delay: delay, type: type)
        var animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: Jazz.valueForTiming(type))
        animation.type = kCATransitionFade
        animation.duration = duration
        self.textLabel.layer.addAnimation(animation, forKey: Jazz.oneShotKey())
    }
    
    //layout the subviews
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel.frame = self.bounds
    }
    
    //process touches to known when to highlight the button
    override public func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if enabled {
            highlighted = true
            drawPath()
        }
    }
    
    //touch ended, remove hightlight
    override public func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if enabled {
            highlighted = false
            drawPath()
        }
    }
    
    //touch cancelled, remove hightlight
    override public func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        if enabled {
            highlighted = false
            drawPath()
        }
    }
    
    //highlight support
    override func drawPath() {
        super.drawPath()
        if highlighted && !ripple {
            if let c = highlightColor {
                self.shapeLayer.fillColor = c.CGColor
            }
        }
    }
    //handle the gesture
    func handleTap(recognizer: UITapGestureRecognizer) {
        if !enabled {
            return
        }
        if ripple {
            drawRipple(recognizer)
        } else if let handler = tapHandler {
            handler()
        }
    }
    
    //draw the ripple effect on the button
    func drawRipple(recognizer: UITapGestureRecognizer) {
        let fadeKey = "fade"
        let moveKey = "move"
        rippleLayer = rippleLayer ?? CAShapeLayer()
        let point = recognizer.locationInView(self)
        let p: CGFloat = self.frame.size.height
        if let rip = rippleLayer {
            rip.fillColor = self.highlightColor?.CGColor
            rip.path = UIBezierPath(roundedRect: CGRectMake(point.x-(p/2), point.y-(p/2), p, p), cornerRadius: self.cornerRadius).CGPath
            rip.opacity = 0.8
            self.shapeLayer.addSublayer(rip)
            self.addSubview(self.textLabel)
        }
        let dur = 0.3
        var animation = Jazz.createAnimation(dur, delay: 0, type: .Linear, key: "opacity")
        animation.fromValue = 0.8
        animation.toValue = 0
        var move = Jazz.createAnimation(dur/2, delay: 0, type: .Linear, key: "path")
        move.fromValue = rippleLayer?.path
        move.toValue = self.shapeLayer.path
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.rippleLayer?.removeFromSuperlayer()
            self.rippleLayer?.removeAnimationForKey(fadeKey)
            self.rippleLayer?.removeAnimationForKey(moveKey)
            if let handler = self.tapHandler {
                handler()
            }
        }
        rippleLayer?.addAnimation(animation, forKey: fadeKey)
        rippleLayer?.addAnimation(move, forKey: moveKey)
        CATransaction.commit()
    }
}