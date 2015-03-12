//
//  LoadingView.swift
//
//  Created by Dalton Cherry on 3/11/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public class LoadingView: UIView, AnimationProtocol {
    
    public var lineWidth: CGFloat = 0.0 //the width of the ring
    public var color: UIColor? //the color of the ring
    public var progress: CGFloat = 0.0 //the progress of the loading. This can be between 0 and 1
    public var shapeLayer: CAShapeLayer! //the layer that represents the view's shape layer
    public var clockwise = true //if the loading should go clockwise or counterclockwise
    private var point:CGFloat = 0
    public var startPoint: CGFloat {
        set{
            point = newValue
            Jazz.rotateView(self, degrees: newValue)
        }
        get{return point}
    }
    private var stopped = false
    private let startKey = "startKey"
    private let endKey = "endKey"
    
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
        self.userInteractionEnabled = false
        self.startPoint = 270
        self.shapeLayer = self.layer as CAShapeLayer
        self.backgroundColor = UIColor.clearColor()
    }
    
    //start the loading animation
    public func start(speed: Double = 1.2) {
        //drawPath()
        runLoading(speed)
    }
    
    //run the loading animation
    private func runLoading(speed: Double) {
        shapeLayer.removeAnimationForKey(startKey)
        shapeLayer.removeAnimationForKey(endKey)
        if stopped {
            stopped = false
            self.progress = 0
            drawPath()
            return
        }
        
        var startAnim = Jazz.createAnimation(speed, delay: speed/1.7, type: .EaseInOut, key: "strokeStart")
        startAnim.fromValue = self.shapeLayer.strokeStart
        startAnim.toValue = 1
        
        var animation = Jazz.createAnimation(speed, delay: 0, type: .EaseInOut, key: "strokeEnd")
        animation.fromValue = self.progress
        animation.toValue = 1
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.shapeLayer.strokeEnd = 1
            self.progress = 0
            self.start(speed: speed)
        }
        shapeLayer.addAnimation(startAnim, forKey: startKey)
        shapeLayer.addAnimation(animation, forKey: endKey)
        CATransaction.commit()
    }
    
    //stop the loading
    public func stop() {
        stopped = true
    }
    
    //animate the progress
    public func animateProgress(speed: Double = 1.2,progress: CGFloat) {
        var animation = Jazz.createAnimation(speed, delay: 0, type: .EaseInOut, key: "strokeEnd")
        animation.fromValue = self.progress
        animation.toValue = progress
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.progress = progress
            self.shapeLayer.removeAnimationForKey(self.endKey)
            self.drawPath()
        }
        shapeLayer.addAnimation(animation, forKey: endKey)
        CATransaction.commit()
    }
    
    //implement the animations
    public func doAnimations(duration: Double, delay: Double, type: CurveType) {
        
        var animation = Jazz.createAnimation(duration, delay: delay, type: type, key: "path")
        animation.fromValue = shapeLayer.path
        animation.toValue = buildPath(self.bounds, width: self.lineWidth, progress: self.progress).CGPath
        shapeLayer.addAnimation(animation, forKey: Jazz.oneShotKey())
        
        var bColor = Jazz.createAnimation(duration, delay: delay, type: type, key: "fillColor")
        bColor.fromValue = shapeLayer.fillColor
        bColor.toValue = self.color?.CGColor
        shapeLayer.addAnimation(bColor, forKey: Jazz.oneShotKey())
        
        var bWidth = Jazz.createAnimation(duration, delay: delay, type: type, key: "lineWidth")
        bWidth.fromValue = shapeLayer.lineWidth
        bWidth.toValue = self.lineWidth
        shapeLayer.addAnimation(bWidth, forKey: Jazz.oneShotKey())
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
    func buildPath(rect: CGRect, width: CGFloat, progress: CGFloat) -> UIBezierPath {
        var pro = progress
        if pro > 1 {
            pro = 1
        } else if pro < 0 {
            pro = 0
        }
        let pad: CGFloat = 1
        var fr = rect
        fr.size.width = floor(rect.size.width-(pad*2))
        fr.size.height = floor(rect.size.height-(pad*2))
        fr.origin.x = pad
        fr.origin.y = pad
        var path = UIBezierPath(ovalInRect: fr)
        shapeLayer.strokeEnd = pro
        return path
    }
    
    //update the shape from the properties
    func drawPath() {
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = self.color?.CGColor
        shapeLayer.lineWidth = self.lineWidth
        shapeLayer.path = buildPath(self.bounds, width: self.lineWidth, progress: self.progress).CGPath
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