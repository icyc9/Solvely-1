//
//  ViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/22/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var answerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionView.layer.cornerRadius = 10
        
        self.answerView.layer.cornerRadius = 10
        self.answerView.layer.borderColor = UIColor.whiteColor().CGColor
        self.answerView.layer.borderWidth = 4
        self.answerView.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

