//
//  HelpPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

class AnswerPopUp: SolvelyPopUp {
    
    static func create(answer: Answer!, delegate: SolvelyPopUpDelegate?) -> AnswerPopUp {
        let popupTitle = label(text: "the answer may be")
        
        let answerLetter = title(text: (answer.identifier ?? "").uppercased())
        
        let answerText = label(text: answer?.text ?? "")
        answerText.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        let disclaimer = multiline(text: "This is a beta. There's always a chance that Solvely's answer is wrong. We are working to improve Solvely's accuracy every day.")
        
        let close = button(text: "Ok")
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            if delegate != nil {
                delegate!.popUpDidClose()
            }
        }
        
        let contents: [UIView] = [
            pad(),
            popupTitle,
            pad(),
            answerLetter,
            answerText,
            pad(height: 24),
            disclaimer,
            pad(),
            close,
            pad(height: 16)
        ]
        
        return AnswerPopUp(contents:contents)
    }
}
