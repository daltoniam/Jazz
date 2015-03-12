//
//  Animator.swift
//
//  Created by Dalton Cherry on 3/10/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public enum CurveType {
    case Linear
    case EaseIn
    case EaseOut
    case EaseInOut
}

public protocol AnimationProtocol {
    //create the animations that are to be preformed for this change to the layer
    func doAnimations(duration: Double, delay: Double, type: CurveType) -> Void
    
    //finish the animation. Normally this means call drawPath() or the method that updates the layer
    func finishAnimation(Void) -> Void
}

class Pending {
    let duration: Double
    let delay: Double
    let animations: ((Void) -> Array<AnimationProtocol>)
    var done: ((Void) -> Void)?
    let type: CurveType
    
    init(_ duration: Double, _ delay: Double = 0, _ type: CurveType = .Linear, _ animations: ((Void) -> Array<AnimationProtocol>)) {
        self.duration = duration
        self.delay = delay
        self.animations = animations
        self.type = type
    }
}

public class Jazz {
    private var pending = Array<Pending>()
    
    //convenience that starts the running
    public convenience init(_ duration: Double = 0.25, delay: Double = 0, type: CurveType = .Linear, animations: ((Void) -> Array<AnimationProtocol>)) {
        self.init()
        play(duration, delay: delay, type: type, animations: animations)
    }
    
    //queue some animations
    public func play(_ duration: Double = 0.25, delay: Double = 0, type: CurveType = .Linear, animations: ((Void) -> Array<AnimationProtocol>)) -> Jazz {
        var should = false
        if self.pending.count == 0 {
            should = true
        }
        self.pending.append(Pending(duration,delay,.Linear,animations))
        if should {
            start(self.pending[0])
        }
        return self
    }
    
    //An animation finished running
    public func done(work:((Void) -> Void)) -> Jazz {
        let anim = Pending(0,0,.Linear,{return []})
        anim.done = work
        self.pending.append(anim)
        return self
    }
    
    //turn a CurveType into the corresponding UIViewAnimationOptions
    class public func valueForView(type: CurveType) -> UIViewAnimationOptions {
        switch type {
        case .EaseIn: return .CurveEaseIn
        case .EaseInOut: return .CurveEaseInOut
        case .EaseOut: return .CurveEaseOut
        default: return .CurveLinear
        }
    }
    
    //turn a CurveType into the corresponding UIViewAnimationCurve
    class public func valueForCurve(type: CurveType) -> UIViewAnimationCurve {
        switch type {
        case .EaseIn: return .EaseIn
        case .EaseInOut: return .EaseInOut
        case .EaseOut: return .EaseOut
        default: return .Linear
        }
    }
    
    //turn a CurveType into the corresponding MediaTiming
    class public func valueForTiming(type: CurveType) -> String {
        switch type {
        case .EaseIn: return kCAMediaTimingFunctionEaseIn
        case .EaseInOut: return kCAMediaTimingFunctionEaseInEaseOut
        case .EaseOut: return kCAMediaTimingFunctionEaseOut
        default: return kCAMediaTimingFunctionLinear
        }
    }
    
    //create a basic animation from the standard properties
    class public func createAnimation(duration: Double, delay: Double, type: CurveType, key: String) -> CABasicAnimation {
        var animation = CABasicAnimation(keyPath: key)
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.timingFunction = CAMediaTimingFunction(name: Jazz.valueForTiming(type))
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        return animation
    }
    
    //creates a random key that is for a single animation
    class public func oneShotKey() -> String {
        let letters = "abcdefghijklmnopqurstuvwxyz"
        var str = ""
        for var i = 0; i < 14; i++ {
            let start = Int(arc4random() % 14)
            str.append(letters[advance(letters.startIndex,start)])
        }
        return "\(Jazz.animPrefix())\(str)"
    }
    
    //the prefix to identify the animations to remove on completion
    class public func animPrefix() -> String {
        return "vluxe"
    }
    
    //private method that actually runs the animation
    private func start(current: Pending) {
        if let d = current.done {
            d()
            self.doFinish()
        } else {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDelay(current.delay)
            UIView.setAnimationDuration(current.duration)
            UIView.setAnimationCurve(Jazz.valueForCurve(current.type))
            let views = current.animations()
            CATransaction.setCompletionBlock {
                for view in views {
                    view.finishAnimation()
                }
                self.doFinish()
            }
            for view in views {
                view.doAnimations(current.duration, delay: current.delay, type: current.type)
            }
            UIView.commitAnimations()
        }
    }
    
    //finish a pending animation
    private func doFinish() {
        self.pending.removeAtIndex(0)
        if self.pending.count > 0 {
            self.start(self.pending[0])
        }
    }
    
    //built in handy animations
    
    ///Public class methods to manipulate views
    
    ///Change the frame of a view
    public class func updateFrame(view :UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        var frame = view.frame
        frame.origin.x = x
        frame.origin.y = y
        frame.size.width = width
        frame.size.height = height
        view.frame = frame
    }
    
    //move the view around
    public class func moveView(view :UIView, x: CGFloat, y: CGFloat) {
        updateFrame(view, x: x, y: y, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    //change the size of the view
    public class func resizeView(view :UIView, width: CGFloat, height: CGFloat) {
        updateFrame(view, x: view.frame.origin.x, y: view.frame.origin.y, width: width, height: height)
    }
    
    //expand the size of the view
    public class func expandView(view :UIView, scale: CGFloat) {
        let w = view.frame.size.width*scale
        let h = view.frame.size.height*scale
        let x = view.frame.origin.x - (w - view.frame.size.width)/2
        let y = view.frame.origin.y - (h - view.frame.size.height)/2
        updateFrame(view, x: x, y: y, width: w, height: h)
    }
    
    //rotate the view
    public class func rotateView(view: UIView, degrees: CGFloat) {
        view.transform = CGAffineTransformRotate(view.transform, degreesToRadians(degrees));
    }
    
    public class func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return ((3.14159265359 * degrees)/180)
    }
}