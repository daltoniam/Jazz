//
//  Jazz.swift
//
//  Created by Dalton Cherry on 1/30/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

class PendingAnim {
    let length: NSTimeInterval
    let delay: NSTimeInterval
    let damping: CGFloat
    let velocity: CGFloat
    let animation: ((Void) -> Void)
    var isDone = false
    
    init(_ length: NSTimeInterval, _ delay: NSTimeInterval = 0, _ springDamping: CGFloat = 1, _ velocity: CGFloat = 1, _ animation: ((Void) -> Void)) {
        self.length = length
        self.delay = delay
        self.damping = springDamping
        self.velocity = velocity
        self.animation = animation
    }
}

public class Jazz {
    
    private var pending = Array<PendingAnim>()
    
    //convenience that starts the running
    public convenience init(_ length: NSTimeInterval, delay: NSTimeInterval = 0, springDamping: CGFloat = 1, velocity: CGFloat = 1, animation: ((Void) -> Void)) {
        self.init()
        play(length, delay: delay, springDamping: springDamping, velocity: velocity, animation: animation)
    }
    
    //queue some animations
    public func play(length: NSTimeInterval, delay: NSTimeInterval = 0, springDamping: CGFloat = 1, velocity: CGFloat = 1, animation:((Void) -> Void)) -> Jazz {
        var should = false
        if self.pending.count == 0 {
            should = true
        }
        self.pending.append(PendingAnim(length,delay,springDamping,velocity,animation))
        if should {
            start(self.pending[0])
        }
        return self
    }
    
    //An animation finished running
    public func done(work:((Void) -> Void)) -> Jazz {
        let anim = PendingAnim(0,0,1,1,work)
        anim.isDone = true
        self.pending.append(anim)
        return self
    }
    
    //private method that actually runs the animation
    private func start(current: PendingAnim) {
        if current.isDone {
            current.animation()
            self.doFinish()
        } else {
            UIView.animateWithDuration(current.length, delay: current.delay, usingSpringWithDamping: current.damping, initialSpringVelocity: current.velocity,
                options: .TransitionNone, animations: current.animation, { (Bool) in
                    self.doFinish()
            })
        }
    }
    
    //finish a pending animation
    private func doFinish() {
        self.pending.removeAtIndex(0)
        if self.pending.count > 0 {
            self.start(self.pending[0])
        }
    }
    
    //convert the degress to radians
    class func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI) / 180;
    }
    
    ///Public class methods to manipulate views
    
    ///Change the frame of a view
    class func updateFrame(view :UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        var frame = view.frame
        frame.origin.x = x
        frame.origin.y = y
        frame.size.width = width
        frame.size.height = height
        view.frame = frame
    }
    
    //move the view around
    class func moveView(view :UIView, x: CGFloat, y: CGFloat) {
        updateFrame(view, x: x, y: y, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    //change the size of the view
    class func resizeView(view :UIView, width: CGFloat, height: CGFloat) {
        updateFrame(view, x: view.frame.origin.x, y: view.frame.origin.y, width: width, height: height)
    }
    
    //expand the size of the view
    class func expandView(view :UIView, scale: CGFloat) {
        let w = view.frame.size.width*scale
        let h = view.frame.size.height*scale
        let x = view.frame.origin.x - (w - view.frame.size.width)/2
        let y = view.frame.origin.y - (h - view.frame.size.height)/2
        updateFrame(view, x: x, y: y, width: w, height: h)
    }
    
    //rotate the view
    class func rotateView(view: UIView, degrees: CGFloat) {
        view.transform = CGAffineTransformRotate(view.transform, degreesToRadians(degrees));
    }
    
    ///Just some builtin convenience animations
    
    ///Attention getter by making the view bounce up and down
    public func bounce(view: UIView, height: CGFloat, delay: NSTimeInterval = 0) -> Jazz {
        let length: NSTimeInterval = 0.20 + NSTimeInterval(height*0.001)
        self.play(length, delay: delay, animation: {
            Jazz.moveView(view, x: view.frame.origin.x, y: view.frame.origin.y-height)
        }).play(length, animation: {
            Jazz.moveView(view, x: view.frame.origin.x, y: view.frame.origin.y+height)
        }).play(length/2, animation: {
            Jazz.moveView(view, x: view.frame.origin.x, y: view.frame.origin.y-(height/2))
        }).play(length/4, animation: {
            Jazz.moveView(view, x: view.frame.origin.x, y: view.frame.origin.y+(height/2))
        })
        return self
    }
    
    ///pulse the view by scaling the view up then back down
    public func pulse(view: UIView, length: NSTimeInterval = 0.5, delay: NSTimeInterval = 0) -> Jazz {
        self.play(length, delay: delay, animation: {
            Jazz.expandView(view, scale: 1.1)
        }).play(length, delay: 0.1, animation: {
            Jazz.expandView(view, scale: 0.9)
        })
        return self
    }
    
    ///fade the view in using the alpha property
    public func fadeIn(view: UIView, length: NSTimeInterval = 1.5, delay: NSTimeInterval = 0) -> Jazz {
        self.play(length, delay: delay, animation: {
            view.alpha = 1
        })
        return self
    }
    
    ///fade the view out using the alpha property
    public func fadeOut(view: UIView, length: NSTimeInterval = 1, delay: NSTimeInterval = 0) -> Jazz {
        self.play(length, delay: delay, animation: {
            view.alpha = 0
        })
        return self
    }
    
}