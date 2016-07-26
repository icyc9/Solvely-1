//
//  CameraViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import CameraEngine

class CameraViewController: UIViewController {

    private let cameraEngine = CameraEngine()
    
    @IBOutlet weak var solveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.solveButton.layer.cornerRadius = 20
        
        self.solveButton.layer.borderWidth = 4
        
        self.solveButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.solveButton.layer.masksToBounds = true
        
        self.cameraEngine.captureDevice
        self.cameraEngine.startSession()
    }

    override func viewDidLayoutSubviews() {
        let layer = self.cameraEngine.previewLayer
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, atIndex: 0)
        self.view.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
