//
//  HomeViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import FastttCamera

class HomeViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let camera = FastttCamera()
        camera.delegate = self
        
        // camera preview should be the size of the camera view
        camera.view.frame = cameraView.frame
        
        camera.view.makeRoundedAndOutline(UIColor.whiteColor())
        cameraView.makeRoundedAndOutline(UIColor.whiteColor())
        
        // add the camera preview to the camera view
        self.fastttAddChildViewController(camera)
        
        let crosshairWidth = 18.0
        let crosshairHeight = 18.0
        
        let x = CGFloat(cameraView.frame.minX + cameraView.frame.size.width * 0.5) - CGFloat(crosshairWidth * 0.5)
        
        let y = CGFloat(cameraView.frame.minY + cameraView.frame.size.height * 0.5) - CGFloat(crosshairHeight * 0.5)
        
        let crosshair = UIView(frame: CGRect(x: x, y: y, width: CGFloat(crosshairWidth), height: CGFloat(crosshairHeight)))
        
        crosshair.backgroundColor = UIColor.solvelyPrimaryBlue()
        crosshair.makeRoundedAndOutline(UIColor.whiteColor())
        
        self.view.addSubview(crosshair)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HomeViewController: FastttCameraDelegate {
    
}