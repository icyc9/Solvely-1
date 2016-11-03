//
//  ErrorPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

class ErrorPopUp: SolvelyPopUp {
    
    static func create(message: String = "Something went wrong", closeable: Bool = true, handler: SelectionHandler?) -> ErrorPopUp {
        let somethingWentWrong = multiline(text: message)
        let sadGif = gif(name: "cry", scale: CGSize(width: 0.25, height: 0.25))
        
        var contents = [
            pad(),
            sadGif,
            somethingWentWrong
        ]
        
        if closeable == true {
            let close = button(text: "Ok!")
            contents.append(pad())
            contents.append(close)
            contents.append(pad())
            
            close.selectionHandler = handler
        }
        
        return ErrorPopUp(contents: contents)
    }
}
