//
//  MCAnswerViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/31/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class MCAnswerViewController: UIViewController {
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerTextLabel: UITextView!

    var answerLetter = ""
    var answerText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.text = answerText
        answerTextLabel.text = answerLetter
    }
}
