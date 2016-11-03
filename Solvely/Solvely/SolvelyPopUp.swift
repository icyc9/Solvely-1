//
//  SolvelyPopUp.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

protocol SolvelyPopUpDelegate {
    func popUpDidClose()
}

class SolvelyPopUp: CNPPopupController {
    
    override init(contents: [UIView]) {
        super.init(contents: contents)
        self.useSolvelyTheme()
    }
}
