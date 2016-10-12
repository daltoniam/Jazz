//
//  Animator.swift
//
//  Created by Dalton Cherry on 3/10/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

public enum CurveType {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

class Pending {
    let duration: Double
    let animations: ((Void) -> Void)
    let type: CurveType
    var delay: Double?
    
    init(_ duration: Double, _ type: CurveType = .linear, _ animations: @escaping ((Void) -> Void)) {
        self.duration = duration
        self.animations = animations
        self.type = type
    }
}

open class Jazz {
    fileprivate var pending = Array<Pending>()
    
    
    //convenience that starts the running
    public init(_ duration: Double = 0.25, type: CurveType = .linear, animations: @escaping ((Void) -> Void)) {
        play(duration, type: type, animations: animations)
    }
    
    public init(delayTime: Double) {
        delay(delayTime)
    }
    
    //queue some animations
    @discardableResult open func play(_ duration: Double = 0.25, delay: Double = 0, type: CurveType = .linear, animations: @escaping ((Void) -> Void)) -> Jazz {
        var should = false
        if pending.count == 0 {
            should = true
        }
        pending.append(Pending(duration,.linear,animations))
        if should {
            start(pending[0])
        }
        return self
    }
    
    //An animation finished running
    @discardableResult open func delay(_ time: Double) -> Jazz {
        let anim = Pending(0,.linear,{})
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
    class open func valueForCurve(_ type: CurveType) -> UIViewAnimationCurve {
        switch type {
        case .easeIn: return .easeIn
        case .easeInOut: return .easeInOut
        case .easeOut: return .easeOut
        default: return .linear
        }
    }
    
    class open func timeFunctionForCurve(_ type: CurveType) -> CAMediaTimingFunction {
        return CAMediaTimingFunction(name: timingFunctionNameForCurve(type))
    }
    //turn a CurveType into the corresponding UIViewAnimationCurve
    class fileprivate func timingFunctionNameForCurve(_ type: CurveType) -> String {
        switch type {
        case .easeIn: return kCAMediaTimingFunctionEaseIn
        case .easeInOut: return kCAMediaTimingFunctionEaseInEaseOut
        case .easeOut: return kCAMediaTimingFunctionEaseOut
        default: return kCAMediaTimingFunctionLinear
        }
    }
    
    //create a basic animation from the standard properties
    class open func createAnimation(_ duration: CFTimeInterval = CATransaction.animationDuration(),
        type: CAMediaTimingFunction = Jazz.timingFunction(), key: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: key)
        animation.duration = duration
        //animation.beginTime = CACurrentMediaTime() + delay
        animation.timingFunction = type
        return animation
    }
    
    //get the timing function or use the default one
    class open func timingFunction() -> CAMediaTimingFunction {
            if let type = CATransaction.animationTimingFunction() {
                return type
            }
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    }
    
    //creates a random key that is for a single animation
    class open func oneShotKey() -> String {
        let letters = "abcdefghijklmnopqurstuvwxyz"
        var str = ""
        for _ in 0 ..< 14 {
            let start = Int(arc4random() % 14)
            str.append(letters[letters.characters.index(letters.startIndex, offsetBy: start)])
        }
        return "vluxe\(str)"
    }
    
    //private method that actually runs the animation
    fileprivate func start(_ current: Pending) {
        if let d = current.delay {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(d * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
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
    fileprivate func doFinish() {
        pending.remove(at: 0)
        if pending.count > 0 {
            start(pending[0])
        }
    }
    
    //built in handy animations
    
    ///Public class methods to manipulate views
    
    ///Change the frame of a view
    open class func updateFrame(_ view :UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        var fr = view.frame
        fr.origin.x = x
        fr.origin.y = y
        fr.size.width = width
        fr.size.height = height
        view.frame = fr
    }
    
    //move the view around
    open class func moveView(_ view :UIView, x: CGFloat, y: CGFloat) {
        updateFrame(view, x: x, y: y, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    //change the size of the view
    open class func resizeView(_ view :UIView, width: CGFloat, height: CGFloat) {
        updateFrame(view, x: view.frame.origin.x, y: view.frame.origin.y, width: width, height: height)
    }
    
    //expand the size of the view
    open class func expandView(_ view :UIView, scale: CGFloat) {
        let w = view.frame.size.width*scale
        let h = view.frame.size.height*scale
        let x = view.frame.origin.x - (w - view.frame.size.width)/2
        let y = view.frame.origin.y - (h - view.frame.size.height)/2
        updateFrame(view, x: x, y: y, width: w, height: h)
    }
    
    //rotate the view
    open class func rotateView(_ view: UIView, degrees: CGFloat) {
        view.transform = view.transform.rotated(by: degreesToRadians(degrees));
    }
    
    open class func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        return ((3.14159265359 * degrees)/180)
    }
}
