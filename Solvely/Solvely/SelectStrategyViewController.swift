//
//  SelectStrategyViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/20/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import TOCropViewController

class SelectStrategyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(patternImage: UIImage(named: "background")!)
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func takePicture(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let crop = TOCropViewController(image: pickedImage)
            
            crop.delegate = self
            
            self.dismissViewControllerAnimated(true) { [weak self] in
                self!.presentViewController(crop, animated: true, completion: nil)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SelectStrategyViewController: TOCropViewControllerDelegate {
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        
    }
}
