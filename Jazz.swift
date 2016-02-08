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

class Pending {
    let duration: Double
    let animations: ((Void) -> Void)
    let type: CurveType
    var delay: Double?
    
    init(_ duration: Double, _ type: CurveType = .Linear, _ animations: ((Void) -> Void)) {
        self.duration = duration
        self.animations = animations
        self.type = type
    }
}

public class Jazz {
    private var pending = Array<Pending>()
    
    
    //convenience that starts the running
    public init(_ duration: Double = 0.25, type: CurveType = .Linear, animations: ((Void) -> Void)) {
        play(duration, type: type, animations: animations)
    }
    
    public init(delayTime: Double) {
        delay(delayTime)
    }
    
    //queue some animations
    public func play(duration: Double = 0.25, delay: Double = 0, type: CurveType = .Linear, animations: ((Void) -> Void)) -> Jazz {
        var should = false
        if pending.count == 0 {
            should = true
        }
        pending.append(Pending(duration,.Linear,animations))
        if should {
            start(pending[0])
        }
        return self
    }
    
    //An animation finished running
    public func delay(time: Double) -> Jazz {
        let anim = Pending(0,.Linear,{return []})
        anim.delay = time
        var should = false
        if pending.count == 0 {
            should = true
        }
        pending.append(anim)
        if should {
            start(pending[0])
        }
        return self
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
    
    class public func timeFunctionForCurve(type: CurveType) -> CAMediaTimingFunction {
        return CAMediaTimingFunction(name: timingFunctionNameForCurve(type))
    }
    //turn a CurveType into the corresponding UIViewAnimationCurve
    class private func timingFunctionNameForCurve(type: CurveType) -> String {
        switch type {
        case .EaseIn: return kCAMediaTimingFunctionEaseIn
        case .EaseInOut: return kCAMediaTimingFunctionEaseInEaseOut
        case .EaseOut: return kCAMediaTimingFunctionEaseOut
        default: return kCAMediaTimingFunctionLinear
        }
    }
    
    //create a basic animation from the standard properties
    class public func createAnimation(duration: CFTimeInterval = CATransaction.animationDuration(),
        type: CAMediaTimingFunction = Jazz.timingFunction(), key: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: key)
        animation.duration = duration
        //animation.beginTime = CACurrentMediaTime() + delay
        animation.timingFunction = type
        return animation
    }
    
    //get the timing function or use the default one
    class public func timingFunction() -> CAMediaTimingFunction {
            if let type = CATransaction.animationTimingFunction() {
                return type
            }
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    }
    
    //creates a random key that is for a single animation
    class public func oneShotKey() -> String {
        let letters = "abcdefghijklmnopqurstuvwxyz"
        var str = ""
        for var i = 0; i < 14; i++ {
            let start = Int(arc4random() % 14)
            str.append(letters[letters.startIndex.advancedBy(start)])
        }
        return "vluxe\(str)"
    }
    
    //private method that actually runs the animation
    private func start(current: Pending) {
        if let d = current.delay {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(d * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.doFinish()
            }
        } else {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(current.duration)
            UIView.setAnimationCurve(Jazz.valueForCurve(current.type))
            CATransaction.setCompletionBlock {
                self.doFinish()
            }
            current.animations()
            UIView.commitAnimations()
        }
    }
    
    //finish a pending animation
    private func doFinish() {
        pending.removeAtIndex(0)
        if pending.count > 0 {
            start(pending[0])
        }
    }
    
    //built in handy animations
    
    ///Public class methods to manipulate views
    
    ///Change the frame of a view
    public class func updateFrame(view :UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        var fr = view.frame
        fr.origin.x = x
        fr.origin.y = y
        fr.size.width = width
        fr.size.height = height
        view.frame = fr
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