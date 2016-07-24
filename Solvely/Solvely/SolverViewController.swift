//
//  SolverViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class SolverViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let check = storyboard.instantiateViewControllerWithIdentifier("check") as! EditQuestionViewController
        
        check.delegate = self
        
        // Add question check page
        self.addChildViewController(check)
        self.containerView.frame = check.view.frame
        self.containerView.addSubview(check.view)
        
        check.didMoveToParentViewController(self)
    }
}

extension SolverViewController: EditQuestionViewControllerDelegate {
    
    func userDidValidateQuestion() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let solving = storyboard.instantiateViewControllerWithIdentifier("solving")
        
        // Add solving check page
        self.addChildViewController(solving)
        self.containerView.frame = solving.view.frame
        self.containerView.addSubview(solving.view)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            // Remove solving page
            solving.willMoveToParentViewController(nil)
            solving.view.removeFromSuperview()
            
            // Add results page
            let answerViewController = storyboard.instantiateViewControllerWithIdentifier("solved")
            
            self.addChildViewController(answerViewController)
            self.containerView.frame = answerViewController.view.frame
            self.containerView.addSubview(answerViewController.view)
        }
    }
}