//
//  LoadingView.swift
//
//  Created by Dalton Cherry on 3/11/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public struct Pose {
    let speed: CFTimeInterval //the speed the animation (the first one in the poses array should be zero)
    let rotationDegrees: CGFloat //set how many degrees the view should rotate by (normally the degrees increase with each pose)
    let length: CGFloat //the length of the progress field to fill
    public init(_ speed: CFTimeInterval, _ rotationDegrees: CGFloat, _ length: CGFloat) {
        self.speed = speed
        self.rotationDegrees = rotationDegrees
        self.length = length
    }
}

public class LoadingView : UIView {
    override public var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    public var poses = [Pose(0.0, 215, 0.3), Pose(0.9, 360, 0.8), Pose(0.5, 575, 0.3)] {
        didSet {
            needsRefresh = true
        }
    }
    public var color = UIColor.blackColor() {
        didSet {
            doStrokeColor()
        }
    }
    
    public var lineWidth: CGFloat = 3.0 {
        didSet {
            doLineWidth()
        }
    }
    public var lineCap = kCALineCapRound {
        didSet {
            drawPath()
        }
    }
    
    //NOTE!!!
    //The startPoint and progress properties should not be used at the same time as the start and stop methods. It just doesn't make sense.
    public var startPoint: CGFloat = 270
    
    //provide a value between 0 and 1
    public var progress: CGFloat = 0 {
        didSet {
            poses = [Pose(0.0, startPoint, oldProgress), Pose(0.9, startPoint, progress)]
            isRunning = true
            doAnimation()
            isRunning = false
            oldProgress = progress
        }
    }
    var oldProgress: CGFloat = 0
    
    var isRunning = false
    var needsRefresh = false
    
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
        backgroundColor = UIColor.clearColor()
    }
    
    //start the animation
    public func start() {
        isRunning = true
        doAnimation()
    }
    
    //stop the animation
    public func stop() {
        isRunning = false
    }
    
    func doAnimation() {
        if !needsRefresh && !isRunning {
            isRunning = false
            layer.removeAllAnimations()
            return
        }
        needsRefresh = false
        
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let totalSeconds = self.poses.reduce(0) { $0 + $1.speed }
        
        for pose in poses {
            time += pose.speed
            times.append(time / totalSeconds)
            rotations.append(Jazz.degreesToRadians(pose.rotationDegrees)) //pose.rotationStart * 2 * CGFloat(M_PI)
            strokeEnds.append(pose.length)
        }
        
        animateKeyPath("strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath("transform.rotation", duration: totalSeconds, times: times, values: rotations)
        
        layer.strokeEnd = strokeEnds.last!
        layer.transform = CATransform3DMakeRotation(rotations.last!, 0, 0, 1)
    }
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if isRunning || needsRefresh {
            doAnimation()
        }
    }
    
    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times
        animation.values = values
        animation.calculationMode = kCAAnimationLinear
        animation.duration = duration
        if keyPath == "strokeEnd" {
            animation.delegate = self
        }
        layer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        drawPath()
        layer.path = UIBezierPath(ovalInRect: CGRectInset(bounds, layer.lineWidth / 2, layer.lineWidth / 2)).CGPath
    }
    
    func drawPath() {
        layer.fillColor = nil
        layer.strokeColor = color.CGColor
        layer.lineWidth = lineWidth
        layer.lineCap = lineCap
    }
    
    //do that fill color
    func doStrokeColor() {
        let animation = Jazz.createAnimation(key: "strokeColor")
        animation.fromValue = layer.strokeColor
        animation.toValue = color.CGColor
        layer.addAnimation(animation, forKey: Jazz.oneShotKey())
        layer.strokeColor = color.CGColor
    }
    
    func doLineWidth() {
        let bWidth = Jazz.createAnimation(key: "lineWidth")
        bWidth.fromValue = layer.lineWidth
        bWidth.toValue = lineWidth
        layer.addAnimation(bWidth, forKey: Jazz.oneShotKey())
        layer.lineWidth = lineWidth
    }
    
    //set the layer of this view to be a shape
    public override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
}