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
    
    var checkProblemController: EditQuestionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        checkProblemController = storyboard.instantiateViewControllerWithIdentifier("check") as? EditQuestionViewController
        
        checkProblemController!.delegate = self
        
        // Add question check page
        self.addChildViewController(checkProblemController!)
        self.containerView.frame = checkProblemController!.view.frame
        self.containerView.addSubview(checkProblemController!.view)
        
        checkProblemController!.didMoveToParentViewController(self)
    }
}

extension SolverViewController: EditQuestionViewControllerDelegate {
    
    func userDidValidateQuestion() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let solving = storyboard.instantiateViewControllerWithIdentifier("solving")
        
        solving.willMoveToParentViewController(nil)
        checkProblemController!.view.removeFromSuperview()
        
        // Add solving check page
        self.addChildViewController(solving)
        self.containerView.addSubview(solving.view)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            // Remove solving page
            solving.willMoveToParentViewController(nil)
            solving.view.removeFromSuperview()
            
            // Add results page
            let answerViewController = storyboard.instantiateViewControllerWithIdentifier("solved")
            

        }
    }
}