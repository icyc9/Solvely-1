//
//  LoadingViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController {
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    @IBOutlet weak var loadingMessageLabel: UILabel!
    
    var loadingMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.type = .BallGridPulse
        indicatorView.startAnimation()
        
        loadingMessageLabel.text = loadingMessage
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}