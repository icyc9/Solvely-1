//
//  EnterQuestionViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/21/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class EnterQuestionViewController: UIViewController {
    @IBOutlet weak var questionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionTextView.delegate = self
        questionTextView.returnKeyType = UIReturnKeyType.Done
        questionTextView.layer.borderColor = Colors.purple.CGColor
        questionTextView.layer.borderWidth = 2
    }
}

extension EnterQuestionViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // Close keyboard on done button (alias for return key)
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}