//
//  EditViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import MBProgressHUD

class EditViewController: UIViewController {

    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var questionTextView: UITextView!
    
    private var hud: MBProgressHUD?
    private let solveService = SolveService()
    
    private let answerViewControllerTitle = "AnswerVC"
    private let errorViewController = "GeneralError"
    private let questionParseErrorViewController =  "QuestionParseError"
    private let placeholderText = "I can answer questions in the following formats.\n\nWho killed Abraham Lincoln?\n A) John Wilkes Booth\n B) Gavrilo Princip\n C) Lee Harvey Oswald\n D) None of the above\n\n and\n\n Who killed Abraham Lincoln?\n\nTap and and enter your question"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        solveService.delegate = self
        solveButton.useRoundedCorners()
        
        questionTextView.delegate = self
        questionTextView.text = placeholderText
        questionTextView.textColor = Colors.basavaGray
    }
    
    @IBAction func answer(sender: UIButton) {
        hud = MBProgressHUD.showHUDAddedTo(self.view!, animated: true)
        hud!.mode = MBProgressHUDMode.Indeterminate
        hud!.labelText = "Answering..."
        hud!.color = Colors.basavaBlue
        
        solveService.solve(self.questionTextView.text)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
}

extension EditViewController: UITextViewDelegate {

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == Colors.basavaGray {
            textView.text = nil
            textView.textColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = Colors.basavaGray
        }
    }
}

extension EditViewController: SolveServiceDelegate {
    
    func questionAnswered(correctAnswer: SolveResult) {
        if hud != nil {
            hud!.hide(true)
            
            let answerViewController = UIStoryboard(name: "Landing", bundle: nil).instantiateViewControllerWithIdentifier(self.answerViewControllerTitle) as! AnsViewController
            
            answerViewController.answer = correctAnswer
            
            self.presentViewController(answerViewController, animated: true, completion: nil)
        }
    }
    
    func unknownError() {
        if hud != nil {
            hud!.hide(true)
        }
        
        let errorViewController = UIStoryboard(name: "Landing", bundle: nil).instantiateViewControllerWithIdentifier(self.errorViewController)
        
        self.presentViewController(errorViewController, animated: true, completion: nil)
    }
    
    func unableToAnswer() {
        if hud != nil {
            hud!.hide(true)
        }
        
        let unableToAnswer = UIStoryboard(name: "Landing", bundle: nil).instantiateViewControllerWithIdentifier(self.questionParseErrorViewController)
        
        self.presentViewController(unableToAnswer, animated: true, completion: nil)
    }
}