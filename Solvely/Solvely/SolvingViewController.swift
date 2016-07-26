//
//  SolvingViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol SolvingViewControllerDelegate {
    func didFinishSolving()
}

class SolvingViewController: UIViewController {

    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    var delegate: SolvingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.type = .BallGridPulse
        indicatorView.startAnimation()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            if self.delegate != nil {
                self.delegate?.didFinishSolving()
            }
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
