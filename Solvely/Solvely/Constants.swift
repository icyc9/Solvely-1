//
//  Constants.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

enum Radius {
    static let standardCornerRadius = CGFloat(8)
}

extension UIView {
    
    func makeRoundedAndOutline(outlineColor: UIColor?) {
        if outlineColor != nil {
            self.makeRounded()
            self.layer.borderColor = outlineColor?.CGColor
        }
    }
    
    func makeRounded() {
        self.layer.cornerRadius = Radius.standardCornerRadius
    }
}

extension UIColor {
    
    static func solvelyPrimaryBlue() -> UIColor {
        return UIColor(red: 0.302, green: 0.5569, blue: 0.9176, alpha: 1.0)
    }
}