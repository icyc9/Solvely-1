//
//  UIView.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/20/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation

extension UIView {
    
    func useCheckeredSolvelyBackground() {
        self.backgroundColor = UIColor.init(patternImage: UIImage(named: "background")!)
    }
    
    func useRoundedCorners() {
        self.layer.cornerRadius = Radius.inputCornerRadius
    }
}