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

class CameraViewController: UIViewController {
    private let cameraEngine = CameraEngine()
    private var popup: PopupViewController?
    private var isFlashToggled = false
    private var solveService: SolveService = SolveService()
    private var ocrText: String = ""
    
    @IBOutlet weak var solveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.solveService.delegate = self

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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.popup = storyboard.instantiateViewControllerWithIdentifier("popup") as? PopupViewController
        
        self.popup!.contentController = content
        
        self.presentViewController(self.popup!, animated: true, completion: nil)
    }
    
    private func crop(image: UIImage) {
        let crop = TOCropViewController(image: image)
        
        crop.delegate = self
        
        self.presentViewController(crop, animated: true, completion: nil)
    }
    
    private func processImage(image: UIImage) {
        let ocrProgressController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loading") as! LoadingViewController
        ocrProgressController.loadingMessage = "Reading your problem..."
        
        self.showPopupWithContent(ocrProgressController)
        
        // Get text from image
        solveService.convertImageToText(image)
    }
}

extension CameraViewController: EditQuestionViewControllerDelegate {
    
    func userDidValidateQuestion() {
        let editedQuestion = (self.popup?.contentController as! EditQuestionViewController).questionTextView.text!
        
        self.popup?.dismissViewControllerAnimated(true) { [weak self] in
            let solvingViewController = self!.storyboard!.instantiateViewControllerWithIdentifier("loading") as? LoadingViewController
            
            solvingViewController?.loadingMessage = "Computing..."
            
            self!.showPopupWithContent(solvingViewController!)
            self!.solveService.solve(editedQuestion)
        }
    }
}

extension CameraViewController: TOCropViewControllerDelegate {
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        
        self.dismissViewControllerAnimated(true, completion: {
            self.processImage(image!)
        })
        
    }
}

extension CameraViewController: SolveServiceDelegate {
    
    func questionText(questionText: String) {
        print("questionText")
        
        self.ocrText = questionText
        
        self.popup?.dismissViewControllerAnimated(true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.popup = storyboard.instantiateViewControllerWithIdentifier("popup") as? PopupViewController
            
            let editProblemViewController = storyboard.instantiateViewControllerWithIdentifier("check") as? EditQuestionViewController
            
            // Set the displayed text to be the OCR output
            editProblemViewController?.questionText = questionText
            editProblemViewController!.delegate = self
            
            self.popup!.contentController = editProblemViewController
            
            // Show a view controller that allows user to edit OCR output
            self.presentViewController(self.popup!, animated: true, completion: nil)
        }
    }
    
    func questionAnswered(answerData: SolveResult) {
        print("questionAnswered")
        
        self.popup?.dismissViewControllerAnimated(true) {[weak self] in
            let solvedViewController = self!.storyboard!.instantiateViewControllerWithIdentifier("solved") as? ResultsViewController
            solvedViewController!.answer = answerData
            
            self!.showPopupWithContent(solvedViewController!)
        }
    }
    
    func unknownError() {
        print("unknownError")
    }
    
    func invalidQuestionFormat() {
        print("invalidQuestionFormat")
        self.popup?.dismissViewControllerAnimated(true) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.popup = storyboard.instantiateViewControllerWithIdentifier("popup") as? PopupViewController
            
            let messageViewController = storyboard.instantiateViewControllerWithIdentifier("bad_question_format") as? UIViewController
            
            self.popup!.contentController = messageViewController
            
            // Show a view controller that allows user to edit OCR output
            self.presentViewController(self.popup!, animated: true, completion: nil)
        }
    }
}