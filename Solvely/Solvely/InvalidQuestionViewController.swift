//
//  InvalidQuestionViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/2/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class InvalidQuestionViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logo.layer.cornerRadius = 20
        self.logo.layer.borderWidth = 4
        self.logo.layer.borderColor = UIColor.whiteColor().CGColor
        self.logo.layer.masksToBounds = true
    }
    
    @IBAction func goBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
