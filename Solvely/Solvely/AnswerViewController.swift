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
    
    var answerIdentifier = ""
    var answer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.text = answerIdentifier
        answerText.text = answer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
