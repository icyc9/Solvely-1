//
//  SummarizationPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation

class SummarizationPopUp: SolvelyPopUp {
    
    static func create(summarizedText: String!) -> SummarizationPopUp {
        
        let contents: [UIView] = [
            title(text: "Summarized"),
            multiline(text: summarizedText),
            button(text: "Got it!")
        ]
        
        let popup = SummarizationPopUp(contents: contents)
        return popup
    }
}
