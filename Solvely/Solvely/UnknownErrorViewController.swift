//
//  UnknownErrorViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/28/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class UnknownErrorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
