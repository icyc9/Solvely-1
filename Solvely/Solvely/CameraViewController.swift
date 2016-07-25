//
//  CameraViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import CameraEngine
import TOCropViewController
import TesseractOCR

class CameraViewController: UIViewController {

    private let cameraEngine = CameraEngine()
    private var popup: PopupViewController?
    private var isFlashToggled = false
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var solveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.solveButton.layer.cornerRadius = 20
        self.solveButton.layer.borderWidth = 4
        self.solveButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.solveButton.layer.masksToBounds = true
        
        self.cameraEngine.cameraFocus = .ContinuousAutoFocus
        self.cameraEngine.captureDevice
        self.cameraEngine.startSession()
    }
    
    override func viewDidLayoutSubviews() {
        let layer = self.cameraEngine.previewLayer
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, atIndex: 0)
        self.view.layer.masksToBounds = true
    }
    
    @IBAction func solve(sender: UIButton) {
        self.cameraEngine.capturePhoto { (image: UIImage?, error: NSError?) -> (Void) in
            self.crop(image!)
        }
    }
    
    @IBAction func toggleFlash(sender: UIButton) {
        isFlashToggled = !isFlashToggled
        
        if isFlashToggled {
            self.cameraEngine.flashMode = .On
        }
        else {
            self.cameraEngine.flashMode = .Off
        }
        
        if isFlashToggled {
            sender.setImage(UIImage(named: "flash on"), forState: UIControlState.Normal)
        }
        else {
            sender.setImage(UIImage(named: "flash off"), forState: UIControlState.Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    }
    
    private func showPopupWithContent(content: UIViewController) {
        self.popup?.dismissViewControllerAnimated(true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.popup = storyboard.instantiateViewControllerWithIdentifier("popup") as? PopupViewController
        
        self.popup!.contentController = content
        
        self.presentViewController(popup!, animated: true, completion: nil)
    }
    
    private func crop(image: UIImage) {
        let crop = TOCropViewController(image: image)
        
        crop.delegate = self
        
        self.presentViewController(crop, animated: true, completion: nil)
    }
    
    private func processImage(image: UIImage) {
        let ocr = OCRService()
        ocr.convertImageToText(image)
//        var tesseract:G8Tesseract = G8Tesseract(language:"eng");
//        //tesseract.language = "eng+ita";
//        tesseract.delegate = nil
//        tesseract.charWhitelist = "01234567890";
//        tesseract.image = image
//        tesseract.recognize();
//        
//        NSLog("%@", tesseract.recognizedText);
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.popup = storyboard.instantiateViewControllerWithIdentifier("popup") as? PopupViewController
        
        let editProblemViewController = storyboard.instantiateViewControllerWithIdentifier("check") as? EditQuestionViewController
        
        editProblemViewController!.delegate = self
        
        self.popup!.contentController = editProblemViewController
        
        self.presentViewController(popup!, animated: true, completion: nil)
    }
}

extension CameraViewController: EditQuestionViewControllerDelegate {
    
    func userDidValidateQuestion() {
        self.popup?.dismissViewControllerAnimated(true, completion: nil)
        
        let solvingViewController = storyboard!.instantiateViewControllerWithIdentifier("solving") as? SolvingViewController
        
        solvingViewController!.delegate = self
        self.showPopupWithContent(solvingViewController!)
    }
}

extension CameraViewController: SolvingViewControllerDelegate {
    
    func didFinishSolving() {
        self.popup?.dismissViewControllerAnimated(true, completion: nil)
        
        let solvingViewController = storyboard!.instantiateViewControllerWithIdentifier("solved") as? QuestionPreviewViewController
        
        self.showPopupWithContent(solvingViewController!)
    }
}

extension CameraViewController: TOCropViewControllerDelegate {
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        
        self.dismissViewControllerAnimated(true, completion: {
            self.previewImage.image = image
            self.processImage(image!)
        })
        
    }
}
