//
//  EditQuestionViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class EditQuestionViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var solveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionTextView.layer.cornerRadius = Radius.inputCornerRadius
        self.solveButton.layer.cornerRadius = Radius.buttonCornerRadius
        self.logo.layer.cornerRadius = 20
        self.logo.layer.borderWidth = 4
        self.logo.layer.borderColor = UIColor.whiteColor().CGColor
        self.logo.layer.masksToBounds = true
    }
    
}
