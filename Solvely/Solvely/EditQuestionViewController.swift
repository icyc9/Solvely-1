//
//  EditQuestionViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

protocol EditQuestionViewControllerDelegate {
    func userDidValidateQuestion()
}

class EditQuestionViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var solveButton: UIButton!
    
    var delegate: EditQuestionViewControllerDelegate?
    var questionText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionTextView.text = questionText
        self.questionTextView.layer.cornerRadius = Radius.inputCornerRadius
        self.solveButton.layer.cornerRadius = Radius.buttonCornerRadius
        self.logo.layer.cornerRadius = 20
        self.logo.layer.borderWidth = 4
        self.logo.layer.borderColor = UIColor.whiteColor().CGColor
        self.logo.layer.masksToBounds = true
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func solve(sender: AnyObject) {
        if delegate != nil {
            delegate?.userDidValidateQuestion()
        }
    }
}
