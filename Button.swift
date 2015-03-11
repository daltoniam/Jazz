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
    private var tapHandler: ((Void) -> Void)?
    
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
        self.autoresizesSubviews = true
        self.setTranslatesAutoresizingMaskIntoConstraints(true)
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.textAlignment = .Center
        textLabel.contentMode = .Center
        textLabel.autoresizingMask = .FlexibleWidth | .FlexibleHeight | .FlexibleLeftMargin | .FlexibleRightMargin
        self.addSubview(textLabel)
        let tap = UITapGestureRecognizer(target: self, action: "didTap")
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
        highlighted = true
        drawPath()
    }
    
    //touch ended, remove hightlight
    override public func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        highlighted = false
        drawPath()
    }
    
    //touch cancelled, remove hightlight
    override public func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        highlighted = false
        drawPath()
    }
    
    //highlight support
    override func drawPath() {
        super.drawPath()
        if highlighted {
            if let c = highlightColor {
                self.shapeLayer.fillColor = c.CGColor
            }
        }
    }
    //handle the gesture
    func didTap() {
        if let handler = tapHandler {
            handler()
        }
    }
}