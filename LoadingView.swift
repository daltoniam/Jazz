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

open class LoadingView : UIView, CAAnimationDelegate {
    override open var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    open var poses = [Pose(0.0, 215, 0.3), Pose(0.9, 360, 0.8), Pose(0.5, 575, 0.3)] {
        didSet {
            needsRefresh = true
        }
    }
    open var color = UIColor.black {
        didSet {
            doStrokeColor()
        }
    }
    
    open var lineWidth: CGFloat = 3.0 {
        didSet {
            doLineWidth()
        }
    }
    open var lineCap = kCALineCapRound {
        didSet {
            drawPath()
        }
    }
    
    override open var frame: CGRect {
        willSet {
            layer.transform = CATransform3DIdentity
        }
        didSet {
            if let last = poses.last, isRunning {
                layer.transform = CATransform3DMakeRotation(Jazz.degreesToRadians(last.rotationDegrees), 0, 0, 1)
            }
        }
    }
    
    override open var isHidden: Bool {
        get {
            return super.isHidden
        }
        set(v) {
            super.isHidden = v
            if v {
                stop()
            }
        }
    }
    
    //NOTE!!!
    //The startPoint and progress properties should not be used at the same time as the start and stop methods. It just doesn't make sense.
    open var startPoint: CGFloat = 270
    
    //provide a value between 0 and 1
    open var progress: CGFloat = 0 {
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
    var didStop: ((Void) -> Void)?
    
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
        isUserInteractionEnabled = false
        backgroundColor = UIColor.clear
    }
    
    //start the animation
    open func start() {
        if isRunning {
            return
        }
        isRunning = true
        doAnimation()
    }
    
    //stop the animation
    open func stop(_ completion: ((Void) -> Void)? = nil) {
        isRunning = false
        didStop = completion
    }
    
    func doAnimation() {
        if !needsRefresh && !isRunning {
            isRunning = false
            layer.removeAllAnimations()
            return
        }
        needsRefresh = false
        if poses.count == 0 {
            return //no pose, no animation
        }
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        let totalSeconds = poses.reduce(0) { $0 + $1.speed }
        
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
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isRunning || needsRefresh {
            doAnimation()
        } else if let complete = didStop {
            complete()
            didStop = nil
        }
    }
    
    func animateKeyPath(_ keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = kCAAnimationLinear
        animation.duration = duration
        if keyPath == "strokeEnd" {
            animation.delegate = self
        }
        layer.add(animation, forKey: animation.keyPath)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        drawPath()
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
        if let last = poses.last , isRunning {
            layer.transform = CATransform3DMakeRotation(Jazz.degreesToRadians(last.rotationDegrees), 0, 0, 1)
        }
    }
    
    func drawPath() {
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = lineCap
    }
    
    //do that fill color
    func doStrokeColor() {
        let animation = Jazz.createAnimation(key: "strokeColor")
        animation.fromValue = layer.strokeColor
        animation.toValue = color.cgColor
        layer.add(animation, forKey: Jazz.oneShotKey())
        layer.strokeColor = color.cgColor
    }
    
    func doLineWidth() {
        let bWidth = Jazz.createAnimation(key: "lineWidth")
        bWidth.fromValue = layer.lineWidth
        bWidth.toValue = lineWidth
        layer.add(bWidth, forKey: Jazz.oneShotKey())
        layer.lineWidth = lineWidth
    }
    
    //set the layer of this view to be a shape
    open override class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        stop()
    }
    
    deinit {
        stop()
    }
}
