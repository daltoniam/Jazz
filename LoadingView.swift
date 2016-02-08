//
//  LoadingView.swift
//
//  Created by Dalton Cherry on 3/11/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public class LoadingView: UIView {
    
    public var clockwise = true //if the loading should go clockwise or counterclockwise
    
    //the width of the ring
    public var lineWidth: CGFloat = 2.0 {
        didSet {
            doLineWidth()
        }
    }
    //the color of the ring
    public var color: UIColor? {
        didSet {
            doStrokeColor()
        }
    }
    //the progress of the loading. This can be between 0 and 1
    public var progress: CGFloat = 0.0 {
        didSet {
            doProgress()
        }
    }
    
    //do the layout updates when the frame updates
    override public var frame: CGRect {
        didSet {
            doLayoutAnimation()
        }
    }
    
    public var shapeLayer: CAShapeLayer! //the layer that represents the view's shape layer
    private var point:CGFloat = 0
    public var startPoint: CGFloat {
        set{
            point = newValue
            Jazz.rotateView(self, degrees: newValue)
        }
        get{return point}
    }
    private var stopped = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //setup the properties
    func commonInit() {
        userInteractionEnabled = false
        startPoint = 270
        shapeLayer = layer as! CAShapeLayer
        backgroundColor = UIColor.clearColor()
        drawPath()
    }
    
    //do that frame layout animation!
    func doLayoutAnimation() {
        if let layer = shapeLayer {
            let newPath = buildPath(frame).CGPath
            let animation = Jazz.createAnimation(key: "path")
            animation.fromValue = layer.path
            animation.toValue = newPath
            layer.addAnimation(animation, forKey: Jazz.oneShotKey())
            layer.path = newPath
        }
    }
    
    //do that fill color
    func doStrokeColor() {
        if let layer = shapeLayer {
            let animation = Jazz.createAnimation(key: "strokeColor")
            animation.fromValue = layer.strokeColor
            animation.toValue = color?.CGColor
            layer.addAnimation(animation, forKey: Jazz.oneShotKey())
            layer.strokeColor = color?.CGColor
        }
    }
    
    //do progress work
    func doProgress() {
        var pro = progress
        if pro > 1 {
            pro = 1
        } else if pro < 0 {
            pro = 0
        }
        if let layer = shapeLayer {
            let animation = Jazz.createAnimation(1.2, type: Jazz.timeFunctionForCurve(.EaseInOut), key: "strokeEnd")
            animation.fromValue = layer.strokeEnd
            animation.toValue = pro
            layer.addAnimation(animation, forKey: Jazz.oneShotKey())
            layer.strokeEnd = pro
        }
    }
    
    //do progress work
    func doLineWidth() {
        if let layer = shapeLayer {
            let bWidth = Jazz.createAnimation(key: "lineWidth")
            bWidth.fromValue = layer.lineWidth
            bWidth.toValue = lineWidth
            layer.addAnimation(bWidth, forKey: Jazz.oneShotKey())
            layer.lineWidth = lineWidth
        }
    }
    
    //start the loading animation
    public func start(speed: Double = 1.2) {
        runLoading(speed)
    }
    
    //run the loading animation
    private func runLoading(speed: CFTimeInterval) {
        if stopped {
            stopped = false
            progress = 0
            return
        }
        
        let startAnim = Jazz.createAnimation(speed, type: Jazz.timeFunctionForCurve(.EaseInOut), key: "strokeStart")
        startAnim.fromValue = shapeLayer.strokeStart
        startAnim.toValue = 1
        
        let animation = Jazz.createAnimation(speed, type: Jazz.timeFunctionForCurve(.EaseInOut), key: "strokeEnd")
        animation.fromValue = progress
        animation.toValue = 1
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.shapeLayer.strokeStart = 0
            self.progress = 0
            self.start(speed)
        }
        shapeLayer.addAnimation(startAnim, forKey: Jazz.oneShotKey())
        shapeLayer.addAnimation(animation, forKey: Jazz.oneShotKey())
        shapeLayer.strokeStart = 1
        shapeLayer.strokeEnd = 1
        CATransaction.commit()
    }
    
    //stop the loading
    public func stop() {
        stopped = true
    }
    
    //creates the shapes path
    func buildPath(rect: CGRect) -> UIBezierPath {
        let pad: CGFloat = 1
        var fr = rect
        fr.size.width = floor(rect.size.width-(pad*2))
        fr.size.height = floor(rect.size.height-(pad*2))
        fr.origin.x = pad
        fr.origin.y = pad
        return UIBezierPath(ovalInRect: fr)
    }
    
    //update the shape from the properties
    func drawPath() {
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = color?.CGColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeEnd = progress
        shapeLayer.path = buildPath(bounds).CGPath
    }
    
    //set the layer of this view to be a shape
    public override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
}