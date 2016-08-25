//
//  GeneralErrorViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class GeneralErrorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tryAgain(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func goBack(sender: UIButton) {
        let home = UIStoryboard(name: "Landing", bundle: nil).instantiateViewControllerWithIdentifier("Home")
        self.presentViewController(home, animated: true, completion: nil)
    }
}
