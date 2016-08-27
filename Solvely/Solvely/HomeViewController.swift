//
//  HomeViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/20/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import BubbleTransition

class HomeViewController: UIViewController {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var askButton: UIButton!
    private let transition = BubbleTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.askButton.useRoundedCorners()
        
        self.greetingLabel.attributedText = self.addBoldText(greetingLabel.text!, boldPartOfString: "Solvely", font: self.greetingLabel.font, boldFont: UIFont.boldSystemFontOfSize(17))
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
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        let bounds = UIScreen.mainScreen().bounds
//        let screenWidth = bounds.width
//        let screenHeight = bounds.height
//        
//        segue.destinationViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
//        segue.destinationViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//        
//        segue.destinationViewController.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight/4)
//    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController
        
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .Custom
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = askButton.center
        transition.bubbleColor = askButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = askButton.center
        transition.bubbleColor = askButton.backgroundColor!
        return transition
    }
}