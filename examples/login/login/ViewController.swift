//
//  ViewController.swift
//  login
//
//  Created by Dalton Cherry on 3/12/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit
import Jazz

class ViewController: UIViewController {
    
    let button = Button(frame: CGRectZero)
    let loadingView = LoadingView(frame: CGRectZero)

    override func viewDidLoad() {
        super.viewDidLoad()
        let imgView = UIImageView(image: UIImage(named: "beach"))
        imgView.contentMode = .Center
        imgView.frame = self.view.bounds
        self.view.addSubview(imgView)
        
        let pad: CGFloat = 10
        let h: CGFloat = 50
        button.frame = CGRectMake(pad, self.view.frame.size.height-(h+pad), self.view.frame.size.width-(pad*2), h)
        button.corners = UIRectCorner.AllCorners
        button.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        button.color = UIColor(red: 253/255.0, green: 56/255.0, blue: 105/255.0, alpha: 1)
        button.highlightColor = UIColor(white: 0.0, alpha: 0.3)
        button.ripple = true
        button.textLabel.text = NSLocalizedString("Sign In", comment: "")
        button.textLabel.textColor = UIColor.whiteColor()
        button.cornerRadius = h/2
        self.view.addSubview(button)
        button.didTap{
            println("apple workaround, button tapped")
            Jazz(0.25, animations: {
                self.button.frame = CGRectMake((self.button.frame.size.width-h)/2, self.button.frame.origin.y, h, h)
                self.button.textLabel.text = ""
                self.button.cornerRadius = h/2
                self.button.enabled = false
                self.loadingView.hidden = false
                let inset: CGFloat = 30
                self.loadingView.frame = CGRectMake(self.button.frame.origin.x+((self.button.frame.size.width-inset)/2),
                    self.button.frame.origin.y+((self.button.frame.size.height-inset)/2), inset, inset)
                self.loadingView.start(speed: 0.5)
                return [self.button,self.loadingView]
            })
        }
        
        loadingView.color = UIColor.whiteColor()
        loadingView.lineWidth = 2
        loadingView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        loadingView.hidden = true
        self.view.addSubview(loadingView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

