//
//  AnsweringPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

class AnsweringPopUp: SolvelyPopUp {
    
    static func create() -> AnsweringPopUp {
        let thinkGif = gif(name: "think")
        
        let contents = [
            pad(),
            thinkGif,
            pad()
        ]
        
        return AnsweringPopUp(contents:contents)
    }
}
