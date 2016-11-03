//
//  HelpPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

class HelpPopUp: SolvelyPopUp {
    
    static func create(delegate: SolvelyPopUpDelegate?) -> HelpPopUp {
        let close = button(text: "Got it!")
        let thinkingGif = gif(name: "think")
        let topTitle = label(text: "** multiple choice questions only")
    
        let contents: [UIView] = [
            thinkingGif,
            pad(),
            close
        ]
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            if delegate != nil {
                delegate!.popUpDidClose()
            }
        }
        
        return HelpPopUp(contents: contents)
    }
}
