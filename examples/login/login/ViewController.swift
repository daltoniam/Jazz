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
        //add the background
        let imgView = UIImageView(image: UIImage(named: "beach"))
        imgView.contentMode = .Center
        imgView.frame = self.view.bounds
        self.view.addSubview(imgView)
        
        let offset: CGFloat = 50
        //add the checkmark
        let checkmark = UIImageView(image: UIImage(named: "checkmark"))
        if let width = checkmark.image?.size.width {
            let checkSize = width/1.5
            checkmark.frame = CGRectMake((self.view.frame.size.width-checkSize)/2, offset, checkSize, checkSize)
            self.view.addSubview(checkmark)
        }
        
        //layout the button and add it to the view
        let pad: CGFloat = 15
        let h: CGFloat = 60
        button.frame = CGRectMake(pad, self.view.frame.size.height-(h+pad+offset), self.view.frame.size.width-(pad*2), h)
        button.corners = UIRectCorner.AllCorners //all the corners are rounded
        button.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        button.color = UIColor(red: 253/255.0, green: 56/255.0, blue: 105/255.0, alpha: 1)
        button.highlightColor = UIColor(white: 0.0, alpha: 0.3)
        button.ripple = true //adds the ripple tap button effect
        button.textLabel.text = NSLocalizedString("Sign In", comment: "")
        button.textLabel.textColor = UIColor.whiteColor()
        button.cornerRadius = h/2 //round the corners
        self.view.addSubview(button)
        
        //handle the button tap
        button.didTap{
            println("apple workaround, button tapped") //I believe this is fixed in swift 1.2
            //Using Jazz, animate the button changes and show the loading dialog
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
            //pretend to send a request for the login
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), {
                sleep(1) //fake wait time here
                //now back to the main thread to do some more drawing
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.bringSubviewToFront(self.button)
                    self.loadingView.stop()
                    //expand the button view to fill the screen and open new view controller
                    Jazz(0.25, animations: {
                        Jazz.expandView(self.button, scale: 12)
                        Jazz.moveView(self.button, x: -(self.button.frame.size.width/4), y: -40)
                        return [self.button]
                    }).play(0.25, animations: {
                        self.button.alpha = 0
                        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
                            if let window = app.window {
                                window.rootViewController = EndController(nibName: nil, bundle: nil)
                            }
                        }
                        return [self.button]
                    })
                })
            })
        }
        
        //add the loading dialog to the view. Hide it since it isn't used at first
        loadingView.color = UIColor.whiteColor()
        loadingView.lineWidth = 2 //how thick is the line of the loading dialog?
        loadingView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        loadingView.hidden = true
        self.view.addSubview(loadingView)
        
        //add the textfields for good measure
        var top = button.frame.origin.y-(offset+h)
        addField(pad, top: top, h: h,text: NSLocalizedString("Password", comment: ""))
        top -= h+20
        addField(pad, top: top, h: h,text: NSLocalizedString("Username", comment: ""))
        
    }
    
    func addField(pad: CGFloat, top: CGFloat, h: CGFloat, text: String) {
        //we could add the icons here for completeness, but I don't want to spend the time to create them right now :).
        //add the textfield
        let field = UITextField(frame: CGRectMake(pad, top, self.button.frame.size.width, h))
        field.textColor = UIColor.whiteColor()
        field.secureTextEntry = true
        field.attributedPlaceholder = NSAttributedString(string: text,
            attributes: [NSForegroundColorAttributeName: field.textColor])
        self.view.addSubview(field)
        
        //add the line view
        let lineView = UIView(frame: CGRectMake(pad, field.frame.size.height+field.frame.origin.y,
            field.frame.size.width, 0.5))
        lineView.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(lineView)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }


}

