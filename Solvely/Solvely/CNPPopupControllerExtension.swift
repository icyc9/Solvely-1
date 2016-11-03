//
//  CNPPopupControllerExtension.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import CNPPopupController

extension CNPPopupController {
    
    func useSolvelyTheme() {
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = UIScreen.main.bounds.width
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(0.75)
        
        self.theme = theme
        self.theme.popupStyle = CNPPopupStyle.centered
    }
    
    static func button(text: String!) -> CNPPopupButton {
        let button = CNPPopupButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        button.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        button.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        button.setTitle(text, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = Radius.standardCornerRadius
        
        return button
    }

    static func pad(height: CGFloat = 8) -> UIView {
        return UIView(frame: CGRect(x: 0, y: 0, width: 1, height: height))
    }
    
    static func title(text: String!) -> UILabel {
        return label(text: text, size: 72)
    }
    
    static func label(text: String!, size: CGFloat = 18.0) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: "Raleway", size: size)
        label.text = text
        label.textAlignment = NSTextAlignment.center;
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        return label
    }
    
    static func multiline(text: String!) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.font = UIFont(name: "Raleway", size: 14)
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 16, height: 50)
        
        return label
    }
}