//
//  SelectStrategyViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/20/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class SelectStrategyViewController: UIViewController {
    @IBOutlet weak var container: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(patternImage: UIImage(named: "background")!)
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
