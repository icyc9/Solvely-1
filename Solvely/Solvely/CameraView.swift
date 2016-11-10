//
//  CameraView.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/8/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import FastttCamera

protocol CameraViewDelegate {
    func didTakeImage(croppedImage: UIImage)
}

class CameraView: UIView{
    var camera: FastttCamera!
    var cropBox: CropBoxView!
    var takePictureButton: UIButton?
    var delegate: CameraViewDelegate?
    var originalSize: CGSize?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setup()
    }
    
    func takePicture(sender: UIButton?) {
        camera.takePicture()
    }
    
    func hideContents() {
        UIView.animate(withDuration: 0.3, animations: {
            self.cropBox.alpha = 0
        })
    }
    
    func showContents() {
        UIView.animate(withDuration: 0.3, animations: {
            self.cropBox.alpha = 1
        })
    }
    
    func cropToBox(screenshot: UIImage) -> UIImage {
        let x = cropBox.frame.minX / UIScreen.main.bounds.width
        let y = cropBox.frame.minY / UIScreen.main.bounds.height
        let w = cropBox.frame.width / UIScreen.main.bounds.width
        let h = cropBox.frame.height / UIScreen.main.bounds.height
        
        
        let x1 = Int(x * screenshot.size.width)
        let y1 = Int(y * screenshot.size.height)
        let x2 = Int(w * screenshot.size.width)
        let y2 = Int(h * screenshot.size.height)
        let cropped = CGRect(x: x1, y: y1, width: x2, height: y2)
        
        print(cropped)
        let cgImage = screenshot.cgImage!.cropping(to: cropped)
        let image: UIImage = UIImage(cgImage: cgImage!)
        return image
    }
    
    private func addCropBox() {
        // Parent view should extend from top of screen to top of squid head
        let centerY = UIScreen.main.bounds.height / 2
        let cropBoxWidth = UIScreen.main.bounds.width
        let cropBoxHeight = UIScreen.main.bounds.height / 3
        
        cropBox = CropBoxView(frame: CGRect(x: 0, y: centerY - (cropBoxHeight / 2), width: cropBoxWidth, height: cropBoxHeight))
        
        addSubview(cropBox)
    }
    
    private func addTakePictureButton() {
        takePictureButton = UIButton(type: .custom)
        
        if let image = UIImage(named: "squid top") {
            takePictureButton?.setImage(image, for: .normal)
            let sw = image.size.width / 2
            let sh = image.size.height / 2
            takePictureButton?.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - (sw / 2), y: UIScreen.main.bounds.height - sh + 5, width: sw, height: sh)
        }
        
        takePictureButton?.addTarget(self, action: #selector(CameraView.takePicture), for: .touchUpInside)
        
        addSubview(takePictureButton!)
    }
    
    private func setup() {
        camera = FastttCamera()
        camera.delegate = self
        addSubview(camera.view)
        
        addTakePictureButton()
        addCropBox()
    }
}

extension CameraView: FastttCameraDelegate {
    
    func cameraController(_ cameraController: FastttCameraInterface!, didFinishNormalizing capturedImage: FastttCapturedImage!) {
        originalSize = capturedImage.fullImage.size
        let image = cropToBox(screenshot: capturedImage.fullImage)
        
        if delegate != nil {
            delegate!.didTakeImage(croppedImage: image)
        }
    }
}
