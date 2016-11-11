//
//  SummarizationPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

class SummarizationPopUp: SolvelyPopUp {
    
    static func create(summarizedText: String!, handler: SelectionHandler?) -> SummarizationPopUp {
        
        let closeButton = button(text: "Got it!")
        
        let contents: [UIView] = [
            pad(),
            title(text: "Summarized:"),
            pad(),
            scrollable(text: summarizedText),
            pad(),
            closeButton,
            pad()
        ]
        
        let popup = SummarizationPopUp(contents: contents)
        closeButton.selectionHandler = handler
        
        return popup
    }
}
