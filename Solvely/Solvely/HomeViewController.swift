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
import NMPopUpViewSwift
import CNPPopupController

class HomeViewController: UIViewController {
    
    private var camera: FastttCamera!
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    private var crosshair: UIView!
    
    private var answeringPopup: CNPPopupController!
    private var unknownErrorPopup: CNPPopupController!
    private var unableToAnswerPopup: CNPPopupController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        camera = FastttCamera()
        camera.delegate = self
        
//        Font: Raleway-Thin
//        Font: Raleway-Light
//        Font: Raleway-Bold
//        Font: Raleway
//        Font: Raleway-Medium
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height
        
        self.view.addSubview(camera.view)
        
        let squid = UIButton(type: .Custom)
        
        if let image = UIImage(named: "squid top") {
            squid.setImage(image, forState: .Normal)
            let sw = image.size.width / 2
            let sh = image.size.height / 2
            squid.frame = CGRect(x: (screenWidth / 2) - (sw / 2), y: screenHeight - sh + 5, width: sw, height: sh)
        }
        
        squid.addTarget(self, action: #selector(HomeViewController.takePicture), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(squid)
        
        let w = CGFloat(screenWidth - 16)
        let h = CGFloat(screenHeight / 3)
        let x = CGFloat((screenWidth / 2 ) - (w / 2))
        let y = CGFloat((screenHeight / 2) - (h / 2))
        
        crosshair = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
        crosshair.userInteractionEnabled = false
        crosshair.makeRounded()
        crosshair.backgroundColor = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0).colorWithAlphaComponent(0.25)
        
        self.view.addSubview(crosshair)
    }
    
    private func crop(image: UIImage!) {
        let crop = TOCropViewController(image: image)
        crop.delegate = self
        self.presentViewController(crop, animated: true, completion: nil)
    }
    
    private func convertImageToText(image: UIImage!) {
        self.ocrService.convertImageToText(image)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: { (text) in
                if text != nil && text != "" {
                    print(text!)
                    self.solve(text!)
                }
                else {
                    self.answeringPopup.dismissPopupControllerAnimated(true)
                    self.unableToAnswerQuestion()
                }
            }, onError: { (error) in
                print(error)
                self.unknownError()
            }, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(self.disposeBag)
    }
    
    func takePicture(sender: UIButton?) {
        camera.takePicture()
    }
    
    private func solve(question: String) {
        solveService.solveQuestion(question)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: { (answer) in
                self.answeringPopup.dismissPopupControllerAnimated(true)
                
                if answer != nil {
                    print(answer?.identifier)
                }
                else {
                    self.unableToAnswerQuestion()
                }
            }, onError: { (error) in
                self.answeringPopup.dismissPopupControllerAnimated(true)
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
        print("unknown error")
        showError("Something went wrong!")
    }
    
    private func showError(message: String?) {
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let somethingWentWrong = UILabel()
        somethingWentWrong.textColor = UIColor.whiteColor()
        somethingWentWrong.font = UIFont(name: "Raleway", size: 18)
        somethingWentWrong.text = message
        somethingWentWrong.textAlignment = NSTextAlignment.Center;
        somethingWentWrong.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        let close = CNPPopupButton(frame: CGRectMake(0, 0, 150, 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), forState: .Normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Close", forState: .Normal)
        close.backgroundColor = UIColor.whiteColor()
        close.layer.cornerRadius = Radius.standardCornerRadius
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.answeringPopup.dismissPopupControllerAnimated(true)
        }
        
        
        let sad = UIImageView(image: UIImage(named: "sad squid"))
        sad.frame = CGRect(x: w / 2, y: 0, width: w / 2, height: w / 2)
        sad.contentMode = .ScaleAspectFit
        
        let topPaddingView = UIView()
        topPaddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        
        theme.cornerRadius = Radius.standardCornerRadius
        theme.backgroundColor = UIColor.solvelyPrimaryBlue()
        
        answeringPopup = CNPPopupController(contents:[topPaddingView, sad, somethingWentWrong, close, paddingView])
        answeringPopup.theme = theme
        answeringPopup.theme.popupStyle = CNPPopupStyle.Centered
        answeringPopup.delegate = nil
        answeringPopup.presentPopupControllerAnimated(true)
    }
    
    private func unableToAnswerQuestion() {
        showError("Couldn't answer that!")
    }
    
    private func showAnsweringViewController() {
        let button = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 60))
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        button.setTitle("Answering", forState: UIControlState.Normal)
        
        let screenWidth = UIScreen.mainScreen().bounds.width

        let w = CGFloat(screenWidth - 20)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let gif = UIImageView(image: UIImage.gifWithName("think"))
        gif.frame = CGRect(x: w / 2, y: y, width: w, height: h)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth - 16
        
        theme.cornerRadius = Radius.standardCornerRadius
        theme.backgroundColor = UIColor.solvelyPrimaryBlue()
        
        answeringPopup = CNPPopupController(contents:[gif])
        answeringPopup.theme = theme
        answeringPopup.theme.popupStyle = CNPPopupStyle.Centered
        answeringPopup.delegate = nil
        answeringPopup.presentPopupControllerAnimated(true)
    }
    
    private func removeViewControllerFromContainer(controller: UIViewController?) {
        controller?.removeFromParentViewController()
        controller?.view.removeFromSuperview()
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