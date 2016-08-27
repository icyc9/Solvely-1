//
//  MultipleChoiceAnswerViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class MultipleChoiceAnswerViewController: UIViewController {
    var answer: SolveResult!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerLabel.text = ""
        
        if answer != nil && answer.answerChoices != nil {
            // concatenate all correct answer letters for the answer title
            for answerChoice in answer.answerChoices! {
                // check if correct answer
                if answerChoice.correctAnswer?.boolValue == true {
                    answerLabel.text = answerLabel.text! + answerChoice.answerIdentifier!
                }
            }
        }
    }
}
