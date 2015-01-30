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
    let animation: ((Void) -> Void)
    var isDone = false
    
    init(_ length: NSTimeInterval, _ delay: NSTimeInterval, _ animation: ((Void) -> Void)) {
        self.length = length
        self.delay = delay
        self.animation = animation
    }
}

public class Jazz {
    
    private var pending = Array<PendingAnim>()
    
    //convenience that starts the running
    public convenience init(_ length: NSTimeInterval, delay: NSTimeInterval, animation: ((Void) -> Void)) {
        self.init()
        play(length, delay: delay, animation: animation)
    }
    
    //queue some animations
    public func play(length: NSTimeInterval, delay: NSTimeInterval, animation:((Void) -> Void)) -> Jazz {
        var should = false
        if self.pending.count == 0 {
            should = true
        }
        self.pending.append(PendingAnim(length,delay,animation))
        if should {
            start(self.pending[0])
        }
        return self
    }
    
    //An animation finished running
    public func done(work:((Void) -> Void)) -> Jazz {
        let anim = PendingAnim(0,0,work)
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
            UIView.animateWithDuration(current.length, delay: current.delay, usingSpringWithDamping: 1, initialSpringVelocity: 1,
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
    
    ///Just some builtin convenience animations
    public func bounce(height: CGFloat, view: UIView) -> Jazz {
        self.play(0.25, delay: 0, {
            var frame = view.frame
            frame.origin.y -= height
            view.frame = frame
        }).play(0.15, delay: 0, {
            var frame = view.frame
            frame.origin.y += height
            view.frame = frame
        }).play(0.15, delay: 0, {
            var frame = view.frame
            frame.origin.y -= (height/2)
            view.frame = frame
        }).play(0.05, delay: 0, {
            var frame = view.frame
            frame.origin.y += (height/2)
            view.frame = frame
        })
        return self
    }
    
}