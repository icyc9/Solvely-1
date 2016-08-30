//
//  AnswerViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class AnswerViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerText: UITextView!
    @IBOutlet weak var shadow: UIView!
    @IBOutlet weak var answerCard: UIView!
    
    var answerIdentifier = ""
    var answer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.text = answerIdentifier
        answerText.text = answer
        shadow.makeRounded()
        answerCard.makeRounded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
