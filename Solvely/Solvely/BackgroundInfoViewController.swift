//
//  BackgroundInfoViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/4/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class BackgroundInfoViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var backgroundInfoTextView: UITextView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var okButton: UIButton!
    
    var topic: String!
    var backgroundInfo: String! = "Abraham Lincoln (Listeni/ˈeɪbrəhæm ˈlɪŋkən/; February 12, 1809 – April 15, 1865) was the 16th President of the United States, serving from March 1861 until his assassination in April 1865. Lincoln led the United States through its Civil War—its bloodiest war and its greatest moral, constitutional, and political crisis.[2][3] In doing so, he preserved the Union, abolished slavery, strengthened the federal government, and modernized the economy."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.layer.cornerRadius = Radius.buttonCornerRadius
        
        self.contentTextView.returnKeyType = UIReturnKeyType.Done
        self.contentTextView.text = backgroundInfo
        self.contentTextView.layer.cornerRadius = Radius.inputCornerRadius
        
        self.logo.layer.cornerRadius = 20
        self.logo.layer.borderWidth = 4
        self.logo.layer.borderColor = UIColor.whiteColor().CGColor
        self.logo.layer.masksToBounds = true
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        
        let underlineAttributedString = NSAttributedString(string: topic, attributes: underlineAttribute)
        
        topicLabel.attributedText = underlineAttributedString
        
    }
    
    @IBAction func goBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
