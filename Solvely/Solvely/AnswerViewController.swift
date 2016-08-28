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
    
    var answer = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.text = answer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
