//
//  ButtonView.swift
//
//  Created by Dalton Cherry on 3/11/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public class ButtonView: ShapeView {
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
    
    //standard view init method
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //standard view init method
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(layout: ShapePath) {
        super.init(layout: layout)
    }
    
    //setup the properties
    override func commonInit() {
        super.commonInit()
        shapeLayer.masksToBounds = true
        autoresizesSubviews = true
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.textAlignment = .Center
        textLabel.contentMode = .Center
        textLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        addSubview(textLabel)
        let tap = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    //handle when the button is tapped
    public func didTap(handler: ((Void) -> Void)) {
        tapHandler = handler
    }
    
    //layout the subviews
    public override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds
    }
    
    //process touches to known when to highlight the button
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        super.touchesBegan(touches, withEvent: event)
        if enabled {
            highlighted = true
            drawPath()
        }
    }
    
    //touch ended, remove hightlight
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if enabled {
            highlighted = false
            drawPath()
        }
    }
    
    //touch cancelled, remove hightlight
    public override func touchesCancelled(touches: Set<UITouch>!, withEvent event: UIEvent!) {
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
            guard let c = highlightColor else {return}
            shapeLayer.fillColor = c.CGColor
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
        let rippleLayer = CAShapeLayer()
        let point = recognizer.locationInView(self)
        let p: CGFloat = frame.size.height
        rippleLayer.fillColor = highlightColor?.CGColor
        rippleLayer.path = UIBezierPath(roundedRect: CGRectMake(point.x-(p/2), point.y-(p/2), p, p), cornerRadius: p/2).CGPath
        rippleLayer.opacity = 0.8
        shapeLayer.addSublayer(rippleLayer)
        addSubview(textLabel)
        
        let dur = 0.3
        let animation = Jazz.createAnimation(dur, key: "opacity")
        animation.fromValue = 0.8
        animation.toValue = 0
        let move = Jazz.createAnimation(dur, key: "path")
        move.fromValue = rippleLayer.path
        move.toValue = shapeLayer.path
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            rippleLayer.removeFromSuperlayer()
            if let handler = self.tapHandler {
                handler()
            }
        }
        rippleLayer.addAnimation(animation, forKey: Jazz.oneShotKey())
        rippleLayer.addAnimation(move, forKey: Jazz.oneShotKey())
        rippleLayer.opacity = 0
        rippleLayer.path = shapeLayer.path
        CATransaction.commit()
    }
}