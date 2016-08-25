//
//  SquidViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import BAFluidView

class SquidViewController: UIViewController {

    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goButton.useRoundedCorners()
    

        
//        self.messageLabel.attributedText = self.addBoldText(messageLabel.text!, boldPartOfString: "Solvely", font: self.messageLabel.font, boldFont: UIFont.boldSystemFontOfSize(17))
        
        goButton.layer.masksToBounds = false
        
        goButton.layer.shadowColor = UIColor.darkGrayColor().CGColor
        
        goButton.layer.shadowOpacity = 0.4
        goButton.layer.shadowRadius = 3
        goButton.layer.shadowOffset = CGSizeMake(2, 2)
    }
    
//    private func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
//        let nonBoldFontAttribute = [NSFontAttributeName:font!]
//        let boldFontAttribute = [NSFontAttributeName:boldFont!]
//        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
//        boldString.addAttributes(boldFontAttribute, range: fullString.rangeOfString(boldPartOfString as String))
//        return boldString
//    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        let fluidView = BAFluidView(frame: self.water.frame, startElevation: 0.5)
//        fluidView.strokeColor = UIColor.whiteColor()
//        fluidView.fillColor = UIColor(hex: 0x2e353d)
//        fluidView!.keepStationary()
//        fluidView!.startAnimation()
//        self.water!.addSubview(fluidView!)

        
//        water.strokeColor = UIColor.whiteColor()
//        water.fillColor = UIColor(hex: 0x2e353d)
//        water!.maxAmplitude = 34
//        water!.minAmplitude = 15
//        water!.fillTo(0.5)
//        water!.keepStationary()
//        water!.startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
