//
//  EnterQuestionViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/21/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import MBProgressHUD

class EnterQuestionViewController: UIViewController {
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var solveButton: UIButton!

    private let solveService = SolveService()
    private var hud: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.solveButton.useRoundedCorners()
        
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)
//        
//        self.navigationController!.navigationBar.translucent = true
//        
//        self.navigationController!.navigationBar.shadowImage = UIImage()
//
//        self.navigationController!.setNavigationBarHidden(false, animated:true)
//        
        self.view.useCheckeredSolvelyBackground()
        
        self.questionTextView.useRoundedCorners()
        self.questionTextView.layer.borderColor = Colors.purple.CGColor
        self.questionTextView.layer.borderWidth = 2
    
        
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(EnterQuestionViewController.doneEditing))
        doneButton.tintColor = UIColor.whiteColor()
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        keyboardToolbar.barTintColor = Colors.purple
        keyboardToolbar.translucent = false
        keyboardToolbar.barStyle = UIBarStyle.Default
        keyboardToolbar.setItems([flexButton, doneButton], animated: true)
        keyboardToolbar.sizeToFit()
        
        questionTextView.inputAccessoryView = keyboardToolbar
        
        solveService.delegate = self
    }
    
    func doneEditing() {
        // close keyboard
        self.questionTextView.endEditing(true)
    }
    
    @IBAction func solve(sender: UIButton) {
        hud = MBProgressHUD.showHUDAddedTo(self.view!, animated: true)
        hud!.mode = MBProgressHUDMode.Indeterminate
        hud!.labelText = "Answering..."
        hud!.color = Colors.purple
        
        solveService.solve(self.questionTextView.text)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
}

extension EnterQuestionViewController: SolveServiceDelegate {
    
    func questionAnswered(correctAnswer: SolveResult) {
        if hud != nil {
            hud!.hide(true)
        }
    }
    
    func unknownError() {
        
    }
    
    func unableToAnswer() {
        
    }
}

//extension EnterQuestionViewController: UITextViewDelegate {
//    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        // Close keyboard on done button (alias for return key)
//        if(text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
//}