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
    @IBOutlet weak var squidGif: UIImageView!
    
    private var camera: FastttCamera!
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    private var answeringViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //squidGif.image = UIImage.gifWithURL("https://media.giphy.com/media/CLLlVrnuuhTq0/giphy.gif")
        
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
        takePictureButton.layer.shadowOpacity = 0.2
        takePictureButton.layer.shadowRadius = 2
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
                    self.dismissViewControllerAnimated(true) { [weak self] in
                        self!.unableToAnswerQuestion()
                    }
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
                self.hideAnsweringViewController()
                
                if answer != nil {
                    print(answer?.identifier)
                    
                    let answerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Answer") as! AnswerViewController
                    
                    answerViewController.answer = answer?.text ?? ""
                    answerViewController.answerIdentifier = (answer?.identifier ?? "").uppercaseString
                    self.presentViewController(answerViewController, animated: true, completion: nil)
                }
                else {
                    self.unableToAnswerQuestion()
                }
            }, onError: { (error) in
                self.hideAnsweringViewController()
                print(error)
                
                switch(error) {
                case SolveError.UnknownError:
                    self.unknownError()
                    break
                case SolveError.InvalidQuestionError:
                    self.unableToAnswerQuestion()
                    break
                default:
                    self.unknownError()
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
    
    private func unknownError() {
        let errorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UnkownError") as! UnknownErrorViewController
        
        self.presentViewController(errorViewController, animated: true, completion: nil)
    }
    
    private func unableToAnswerQuestion() {
        // Show no message error
        let unableToReadQuestionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("QuestionParseError") as! UnableToReadQuestionViewController
        
        self.presentViewController(unableToReadQuestionViewController, animated: true, completion: nil)
    }
    
    private func hideAnsweringViewController() {
        answeringViewController?.dismissViewControllerAnimated(true, completion: nil)
        answeringViewController = nil
    }
    
    private func showAnsweringViewController() {
        answeringViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Answering") 
        self.presentViewController(answeringViewController!, animated: true, completion: nil)
    }
}

extension HomeViewController: FastttCameraDelegate {
    
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        self.crop(capturedImage.scaledImage)
    }
}


extension HomeViewController: TOCropViewControllerDelegate {
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        
        self.dismissViewControllerAnimated(true, completion: { [weak self] in
            self!.showAnsweringViewController()
            self!.convertImageToText(image)
        })
        
    }
}