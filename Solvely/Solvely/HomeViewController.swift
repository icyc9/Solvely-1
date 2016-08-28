//
//  HomeViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import FastttCamera
import TOCropViewController
import RxSwift

class HomeViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var takePictureButton: UIButton!
    
    private var camera: FastttCamera!
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera = FastttCamera()
        camera.delegate = self
        
        // add the camera preview to the camera view
        self.fastttAddChildViewController(camera)
        
        camera.view.makeRoundedAndOutline(UIColor.whiteColor())
        cameraView.makeRoundedAndOutline(UIColor.whiteColor())
       
        // Add shadow and make it rounded
        takePictureButton.makeRounded()
        takePictureButton.layer.masksToBounds = false
        takePictureButton.layer.shadowColor = UIColor.darkGrayColor().CGColor
        takePictureButton.layer.shadowOpacity = 0.4
        takePictureButton.layer.shadowRadius = 3
        takePictureButton.layer.shadowOffset = CGSizeMake(2, 2)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // camera preview should be the size of the camera view
        camera.view.frame = cameraView.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func takePicture(sender: UIButton) {
        camera.takePicture()
    }
    
    private func crop(image: UIImage!) {
        let crop = TOCropViewController(image: image)
        crop.delegate = self
        self.presentViewController(crop, animated: true, completion: nil)
    }
    
    private func addCrosshair() {
        let crosshairWidth = 18.0
        let crosshairHeight = 18.0
        
        let x = CGFloat(cameraView.frame.minX + cameraView.frame.size.width * 0.5) - CGFloat(crosshairWidth * 0.5)
        
        let y = CGFloat(cameraView.frame.minY + cameraView.frame.size.height * 0.5) - CGFloat(crosshairHeight * 0.5)
        
        let crosshair = UIView(frame: CGRect(x: x, y: y, width: CGFloat(crosshairWidth), height: CGFloat(crosshairHeight)))
        
        crosshair.backgroundColor = UIColor.solvelyPrimaryBlue()
        crosshair.makeRoundedAndOutline(UIColor.whiteColor())
        
        self.view.addSubview(crosshair)
    }
    
    private func convertImageToText(image: UIImage!) {
        self.ocrService.convertImageToText(image)
            .subscribeOn(MainScheduler.instance)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: { (text) in
                if text != nil && text != "" {
                    print(text!)
                    self.solve(text!)
                }
                else {
                    // todo: Show message saying OCR returned nothing
                }
            }, onError: { (error) in
                print(error)
            }, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(self.disposeBag)
    }
    
    private func solve(question: String) {
        solveService.solveQuestion(question)
            .subscribeOn(MainScheduler.instance)
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: { (answer) in
                if answer != nil {
                    print(answer?.identifier)
                    
                    let answerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Answer") as! AnswerViewController
                    answerViewController.answer = answer?.identifier ?? ""
                    self.presentViewController(answerViewController, animated: true, completion: nil)
                }
                else {
                    // todo: Show message saying there is no answer
                }
            }, onError: { (error) in
                    print(error)
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
}

extension HomeViewController: FastttCameraDelegate {
    
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        
        self.crop(capturedImage.scaledImage)
    }
}


extension HomeViewController: TOCropViewControllerDelegate {
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        
        self.dismissViewControllerAnimated(true, completion: {
            self.convertImageToText(image)
        })
        
    }
}