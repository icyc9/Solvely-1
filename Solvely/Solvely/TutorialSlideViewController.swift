//
//  TutorialSlideViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class TutorialSlideViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var imageName = ""
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = text
        image.image = UIImage(named: imageName)
        
        // Bold any occurence of "Solvely" in the message
        if self.titleLabel.text?.containsString("Solvely") == true {
            self.titleLabel.attributedText = self.addBoldText(titleLabel.text!, boldPartOfString: "Solvely", font: self.titleLabel.font, boldFont: UIFont.boldSystemFontOfSize(20))
        }
    }
    
    private func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSFontAttributeName:font!]
        let boldFontAttribute = [NSFontAttributeName:boldFont!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.rangeOfString(boldPartOfString as String))
        return boldString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
