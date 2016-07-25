//
//  PopupViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/24/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
    @IBOutlet weak var contentContainer: UIView!
    var contentController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        self.contentController!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight / 2)

        if contentController != nil {
            self.contentContainer.frame = contentController!.view.frame
            self.addChildViewController(contentController!)
            self.contentContainer.addSubview(contentController!.view)
        }
    }
}
