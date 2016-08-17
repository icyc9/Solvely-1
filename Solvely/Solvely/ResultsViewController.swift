//
//  ResultsViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/5/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    var answer: SolveResult!
    var answerViewController: AnswerViewController?
    var conceptViewController: ConceptViewController?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnswerController()
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            showAnswerController()
            break
        case 1:
            showConceptController()
            break
        default:
            break
        }
    }
    
    private func showConceptController() {
        if conceptViewController == nil {
            conceptViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("concepts") as! ConceptViewController
            var concepts: [BackgroundInfo]? = []
            
            if answerViewController != nil {
                answerViewController?.removeFromParentViewController()
                answerViewController?.view.removeFromSuperview()
                answerViewController = nil
            }
            
            if answer != nil {
                if answer!.question?.backgroundInfo != nil {
                    for info in (answer!.question?.backgroundInfo!)! {
                        concepts?.append(info)
                    }
                }
                
                if answer!.answerChoices != nil {
                    for ans in answer!.answerChoices! {
                        if ans.backgroundInfo != nil {
                            for info in ans.backgroundInfo! {
                                concepts?.append(info)
                            }
                        }
                    }
                }
            }
            
            conceptViewController!.concepts = concepts
            
            self.addChildViewController(conceptViewController!)
            self.containerView.addSubview(conceptViewController!.view)
        }
    }
    
    private func showAnswerController() {
        if answerViewController == nil {
            answerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("answer") as! AnswerViewController
            answerViewController?.answer = answer
            print(answer)
            if conceptViewController != nil {
                conceptViewController?.removeFromParentViewController()
                conceptViewController?.view.removeFromSuperview()
                conceptViewController = nil
            }
            
            self.containerView.frame = answerViewController!.view.frame
            self.addChildViewController(answerViewController!)
            self.containerView.addSubview(answerViewController!.view)
        }
    }
}
