//
//  ButtonView.swift
//
//  Created by Dalton Cherry on 3/11/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

open class ButtonView: ShapeView {
    fileprivate var highlighted = false
    open var isHightlighted: Bool {return highlighted}
    open var highlightColor: UIColor?
    open var textLabel: UILabel = UILabel()
    open var enabled: Bool = true {
        didSet {
           textLabel.isEnabled = enabled
        }
    }
    open var ripple = false
    open var didTap: ((Void) -> Void)?
    
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
        layer.masksToBounds = true
        autoresizesSubviews = true
        textLabel.backgroundColor = UIColor.clear
        textLabel.textAlignment = .center
        textLabel.contentMode = .center
        textLabel.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        addSubview(textLabel)
        let tap = UITapGestureRecognizer(target: self, action:#selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    //layout the subviews
    open override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds
    }
    
    //process touches to known when to highlight the button
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        super.touchesBegan(touches, with: event)
        if enabled {
            highlighted = true
            drawPath()
        }
    }
    
    //touch ended, remove hightlight
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if enabled {
            highlighted = false
            drawPath()
        }
    }
    
    //touch cancelled, remove hightlight
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent!) {
        super.touchesCancelled(touches, with: event)
        if enabled {
            highlighted = false
            drawPath()
        }
    }
    
    //highlight support
    override open func drawPath() {
        super.drawPath()
        if highlighted && !ripple {
            guard let c = highlightColor else {return}
            layer.fillColor = c.cgColor
        }
    }
    //handle the gesture
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        if !enabled {
            return
        }
        if ripple {
            drawRipple(recognizer)
        } else if let handler = didTap {
            handler()
        }
    }
    
    //draw the ripple effect on the button
    func drawRipple(_ recognizer: UITapGestureRecognizer) {
        let rippleLayer = CAShapeLayer()
        let point = recognizer.location(in: self)
        let p: CGFloat = frame.size.height
        rippleLayer.fillColor = highlightColor?.cgColor
        rippleLayer.path = UIBezierPath(roundedRect: CGRect(x: point.x-(p/2), y: point.y-(p/2), width: p, height: p), cornerRadius: p/2).cgPath
        rippleLayer.opacity = 0.8
        layer.addSublayer(rippleLayer)
        addSubview(textLabel)
        
        let dur = 0.3
        let animation = Jazz.createAnimation(dur, key: "opacity")
        animation.fromValue = 0.8
        animation.toValue = 0
        let move = Jazz.createAnimation(dur, key: "path")
        move.fromValue = rippleLayer.path
        move.toValue = layer.path
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            rippleLayer.removeFromSuperlayer()
            if let handler = self.didTap {
                handler()
            }
        }
        rippleLayer.add(animation, forKey: Jazz.oneShotKey())
        rippleLayer.add(move, forKey: Jazz.oneShotKey())
        rippleLayer.opacity = 0
        rippleLayer.path = layer.path
        CATransaction.commit()
    }
}
