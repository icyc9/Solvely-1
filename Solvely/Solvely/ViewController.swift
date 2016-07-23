//
//  ViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/22/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import CameraEngine

class ViewController: UIViewController {

    private let cameraEngine = CameraEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

