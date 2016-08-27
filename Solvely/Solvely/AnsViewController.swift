//
//  AnsViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class AnsViewController: UIViewController {
    @IBOutlet weak var answerLetterLabel: UILabel!
    
    var answer: SolveResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if answer != nil && answer?.answerChoices != nil {
            for a in (answer?.answerChoices!)! {
                if a.correctAnswer?.boolValue == true {
                    self.answerLetterLabel.text = a.answerIdentifier?.uppercaseString
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
