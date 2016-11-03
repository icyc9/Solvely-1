//
//  EditQuestionPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

protocol EditQuestionPopUpDelegate: SolvelyPopUpDelegate {
    func didPressSolve(editedQuestion: String!)
}

class EditQuestionPopUp: SolvelyPopUp {
    var editQuestionPopUpDelegate: EditQuestionPopUpDelegate?
    
    static func create(questionText: String!, delegate: EditQuestionPopUpDelegate?) -> EditQuestionPopUp {
        let titleLabel = label(text: "Edit your question")
        
        let editQuestionTextView = textView(text: questionText)
        
        let solve = button(text: "Solve")
        let retake = button(text: "Retake")
        
        let contents: [UIView] = [
            pad(),
            titleLabel,
            editQuestionTextView,
            pad(),
            retake,
            pad(),
            solve,
            pad()
        ]
        
        let popup = EditQuestionPopUp(contents: contents)
        popup.editQuestionPopUpDelegate = delegate
        
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: popup, action: #selector(
            EditQuestionPopUp.doneEditingQuestion))
        
        doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 17)!], for: UIControlState.normal)
        doneButton.tintColor = UIColor.solvelyPrimaryBlue()
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        keyboardToolbar.barTintColor = UIColor.white
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barStyle = UIBarStyle.default
        keyboardToolbar.setItems([flexButton, doneButton], animated: true)
        keyboardToolbar.sizeToFit()
        
        editQuestionTextView.inputAccessoryView = keyboardToolbar
        
        retake.selectionHandler = {(button: CNPPopupButton!) -> Void in
            popup.retake()
        }
        
        solve.selectionHandler = {(button: CNPPopupButton!) -> Void in
            popup.solve(questionText: editQuestionTextView.text)
        }
        
        return popup
    }
    
    func solve(questionText: String!) {
        dismiss(animated: true)
        
        if editQuestionPopUpDelegate != nil {
            editQuestionPopUpDelegate?.didPressSolve(editedQuestion: questionText)
        }
    }
    
    func retake() {
        dismiss(animated: true)
        
        if editQuestionPopUpDelegate != nil {
            editQuestionPopUpDelegate?.popUpDidClose()
        }
    }
    
    func doneEditingQuestion(sender: UIBarButtonItem?) {
        self.dismiss(animated: true)
        if editQuestionPopUpDelegate != nil {
            editQuestionPopUpDelegate?.popUpDidClose()
        }
    }
}
