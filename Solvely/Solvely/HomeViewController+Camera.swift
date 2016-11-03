//
//  HomeViewController+Camera.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import FastttCamera

extension HomeViewController: FastttCameraDelegate {
    
    func takePicture(sender: UIButton?) {
        camera.takePicture()
    }
    
    func cropToBox(screenshot: UIImage) -> UIImage {
        let x = cropBox.bounds.minX / self.view.frame.width
        let y = cropBox.bounds.minY / self.view.frame.height
        let w = cropBox.bounds.width / self.view.frame.width
        let h = cropBox.bounds.height / self.view.frame.height
        
        let cropped = CGRect(x: x * screenshot.size.width, y: y * screenshot.size.height, width: w * screenshot.size.width, height: h * screenshot.size.height)
        
        print(cropped)
        let cgImage = screenshot.cgImage!.cropping(to: cropped)
        let image: UIImage = UIImage(cgImage: cgImage!)
        return image
    }
    
    func cameraController(_ cameraController: FastttCameraInterface!, didFinishCapturing capturedImage: FastttCapturedImage!) {
        print(capturedImage.fullImage.size)
    }
}
