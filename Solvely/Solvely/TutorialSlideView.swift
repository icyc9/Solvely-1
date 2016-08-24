//
//  TutorialSlideView.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class TutorialSlideView: UIView {
    
    @IBOutlet weak var view: UIView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        NSBundle.mainBundle().loadNibNamed("TutorialSlideView", owner: self, options: nil)
        
        self.addSubview(self.view)
    }
}
