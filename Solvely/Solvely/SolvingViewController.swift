//
//  SolvingViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SolvingViewController: UIViewController {

    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.type = .BallGridPulse
        indicatorView.startAnimation()
    }
    
}
