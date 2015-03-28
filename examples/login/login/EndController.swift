//
//  EndController.swift
//  login
//
//  Created by Dalton Cherry on 3/27/15.
//  Copyright (c) 2015 Vluxe. All rights reserved.
//

import UIKit

class EndController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let h: CGFloat = 30
        let label = UILabel(frame: CGRectMake(0, (self.view.frame.size.height-h)/2, self.view.frame.size.width, h))
        label.text = NSLocalizedString("Hello World!", comment: "")
        self.view.addSubview(label)
    }
}
