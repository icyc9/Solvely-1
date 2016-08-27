//
//  SelectSolveMethodViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/26/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import TOCropViewController
import TesseractOCR
import GPUImage

class SelectSolveMethodViewController: UIViewController, UINavigationControllerDelegate {
    var imagePicker: UIImagePickerController!
    //var tesseract = G8Tesseract(language:"eng")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func takePicture(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    private func processImage(image: UIImage) {
        let service = OCRService()
        service.googleOCR(image)
        
        // Initialize our adaptive threshold filter
//        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
//        stillImageFilter.blurRadiusInPixels = 20
//        
//        let processed = stillImageFilter.imageByFilteringImage(image)
//        print("preprocessed")
//        
//        let first = NSDate.init().timeIntervalSince1970
//    
//        
//        //tesseract.language = "eng+ita";
//        //tesseract.delegate = self;
//        tesseract.charWhitelist = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789.?)";
//        tesseract.image = image
//        tesseract.recognize();
//        
//        print(NSDate.init().timeIntervalSince1970 - first)
//        print("getting blocks")
//        let paragraphs = tesseract.recognizedBlocksByIteratorLevel(G8PageIteratorLevel.Paragraph)
//        
//        print("paragraph")
//        print((paragraphs[0] as! G8RecognizedBlock).boundingBoxAtImageOfSize(image.size))
//        crop(image.imageByCroppingToRect((paragraphs[0] as! G8RecognizedBlock).boundingBoxAtImageOfSize(image.size))!)
        
        //var imageWithBlocks = tesseract.imageWithBlocks(paragraphs, drawText: false, thresholded: true)
        
//        NSLog("%@", tesseract.recognizedText);

    }
    
    private func crop(image: UIImage) {
        let crop = TOCropViewController(image: image)
        
        crop.delegate = self
        
        self.presentViewController(crop, animated: true, completion: nil)
    }
}


extension SelectSolveMethodViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        if info[UIImagePickerControllerOriginalImage] != nil {
            // crop taken picture
            crop(info[UIImagePickerControllerOriginalImage] as! UIImage)
        }
    }
}

extension SelectSolveMethodViewController: TOCropViewControllerDelegate {
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        
        self.dismissViewControllerAnimated(true, completion: {
            self.processImage(image!)
        })
        
    }
}

public extension UIImage {
    func imageByCroppingToRect(rect: CGRect) -> UIImage? {
        if let image = CGImageCreateWithImageInRect(self.CGImage, rect) {
            return UIImage(CGImage: image)
        } else if let image = (self.CIImage)?.imageByCroppingToRect(rect) {
            return UIImage(CIImage: image)
        }
        return nil
    }
}
