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

    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var answerView: UIView!
    
    private let cameraEngine = CameraEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraEngine.captureDevice
        self.cameraEngine.startSession()
        
        self.questionView.layer.cornerRadius = 10
        
        self.answerView.layer.cornerRadius = 10
        self.answerView.layer.borderColor = UIColor.whiteColor().CGColor
        self.answerView.layer.borderWidth = 4
        self.answerView.layer.masksToBounds = true
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

