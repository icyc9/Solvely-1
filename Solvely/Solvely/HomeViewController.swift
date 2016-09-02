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
import FirebaseAnalytics

class HomeViewController: UIViewController {
    private let hasSolvedKey = "hasSolved"
    
    private var camera: FastttCamera!
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    private var crosshair: UIView!
    
    private var answeringPopup: CNPPopupController!
    private var unknownErrorPopup: CNPPopupController!
    private var unableToAnswerPopup: CNPPopupController!
    private var answerPopup: CNPPopupController!
    
    private var crosshairX: CGFloat = 0
    private var crosshairY: CGFloat = 0
    private var crosshairW: CGFloat = 0
    private var crosshairH: CGFloat = 0
    
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
        
        crosshairW = CGFloat(screenWidth - 16)
        crosshairH = CGFloat(screenHeight / 3)
        crosshairX = CGFloat((screenWidth / 2 ) - (crosshairW / 2))
        crosshairY = CGFloat((screenHeight / 2) - (crosshairH / 2))
        
        crosshair = UIView(frame: CGRect(x: crosshairX, y: crosshairY, width: crosshairW, height: crosshairH))
        crosshair.userInteractionEnabled = false
        crosshair.makeRounded()
        crosshair.backgroundColor = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0).colorWithAlphaComponent(0.4)
        
        self.view.addSubview(crosshair)
        
        let help = UIButton(type: .Custom)
        
        if let image = UIImage(named: "help") {
            help.setImage(image, forState: .Normal)
            let hw = image.size.width
            let hh = image.size.height
            help.frame = CGRect(x: screenWidth - hw - 8, y: screenHeight - hh - 8, width: hw, height: hh)
            help.addTarget(self, action: #selector(HomeViewController.showHelp), forControlEvents: .TouchUpInside)
        }
        
        self.view.addSubview(help)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        let defaults = NSUserDefaults.standardUserDefaults()
        let hasSolvedQuestion = defaults.valueForKey(hasSolvedKey) as? Bool
        
        if hasSolvedQuestion == nil || hasSolvedQuestion == false {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(true, forKey: self.hasSolvedKey)
            
            showHelp(nil)
        }
    }
    
    private func crop(image: UIImage!) {
        let cropped = cropToBox(image)
        
        let crop = TOCropViewController(image: cropped)
        crop.delegate = self
        self.presentViewController(crop, animated: true, completion: nil)
    }
    
    func cropToBox(screenshot: UIImage) -> UIImage {
        let x = crosshairX / self.view.frame.width
        let y = crosshairY / self.view.frame.height
        let w = crosshairW / self.view.frame.width
        let h = crosshairH / self.view.frame.height
        
        let cropped = CGRect(x: x * screenshot.size.width, y: y * screenshot.size.height, width: w * screenshot.size.width, height: h * screenshot.size.height)
        
        print(cropped)
        let cgImage = CGImageCreateWithImageInRect(screenshot.CGImage, cropped)
        let image: UIImage = UIImage(CGImage: cgImage!)
        return image
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
                self.answeringPopup.dismissPopupControllerAnimated(true)
                self.unknownError()
            }, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(self.disposeBag)
    }
    
    func takePicture(sender: UIButton?) {
        FIRAnalytics.logEventWithName("takePicture", parameters: [:])
        
        camera.takePicture()
    }
    
    private func solve(question: String) {
        solveService.solveQuestion(question)
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: { (answer) in
                self.answeringPopup.dismissPopupControllerAnimated(true)
                    
                if answer != nil {
                    self.showAnswer(answer)
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
    
    func showHelp(sender: UIButton?) {
        FIRAnalytics.logEventWithName("showHelp", parameters: [:])
        
        let close = CNPPopupButton(frame: CGRectMake(0, 0, 150, 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), forState: .Normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Ok", forState: .Normal)
        close.backgroundColor = UIColor.whiteColor()
        close.layer.cornerRadius = Radius.standardCornerRadius
        
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let gif = UIImageView(image: UIImage.gifWithName("think"))
        gif.contentMode = .ScaleAspectFit
        gif.frame = CGRect(x: w / 2, y: y, width: w / 2, height: w / 2)
        
        let message = UILabel()
        message.textColor = UIColor.whiteColor()
        message.font = UIFont(name: "Raleway", size: 17)
        message.numberOfLines = 0
        message.textAlignment = NSTextAlignment.Center
        message.lineBreakMode = NSLineBreakMode.ByWordWrapping
        message.text = "Hey there! I'm Solvely. I'll answer your fact based multiple choice questions."
        message.textAlignment = NSTextAlignment.Center;
        message.frame = CGRect(x: 0, y: 0, width: screenWidth - 40 - 20, height: 100)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        
        theme.cornerRadius = Radius.standardCornerRadius
        theme.backgroundColor = UIColor.solvelyPrimaryBlue()
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let helpPopup = CNPPopupController(contents:[gif, message, paddingView2, close, paddingView])
        helpPopup.theme = theme
        helpPopup.theme.popupStyle = CNPPopupStyle.Centered
        helpPopup.delegate = nil
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            helpPopup.dismissPopupControllerAnimated(true)
        }
        
        helpPopup.presentPopupControllerAnimated(true)
    }
    
    private func showAnswer(answer: Answer?) {
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let title = UILabel()
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "Raleway", size: 18)
        title.text = "The answer is most likely"
        title.textAlignment = NSTextAlignment.Center;
        title.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        let answerLetter = UILabel()
        answerLetter.textColor = UIColor.whiteColor()
        answerLetter.font = UIFont(name: "Raleway", size: 64)
        answerLetter.text = (answer?.identifier ?? "").uppercaseString
        answerLetter.textAlignment = NSTextAlignment.Center;
        answerLetter.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        let answerText = UILabel()
        answerText.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        answerText.textColor = UIColor.whiteColor()
        answerText.font = UIFont(name: "Raleway", size: 24)
        answerText.text = answer?.text ?? ""
        answerText.textAlignment = NSTextAlignment.Center;
        answerText.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        let close = CNPPopupButton(frame: CGRectMake(0, 0, 150, 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), forState: .Normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Ok", forState: .Normal)
        close.backgroundColor = UIColor.whiteColor()
        close.layer.cornerRadius = Radius.standardCornerRadius
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.answerPopup.dismissPopupControllerAnimated(true)
            FIRAnalytics.logEventWithName("acceptAnswer", parameters: [:])
        }
        
        let topPaddingView = UIView()
        topPaddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView3 = UIView()
        paddingView3.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        
        theme.cornerRadius = Radius.standardCornerRadius
        theme.backgroundColor = UIColor.solvelyPrimaryBlue()
        
        answerPopup = CNPPopupController(contents:[topPaddingView, title, paddingView3, answerLetter, answerText, paddingView2, close, paddingView])
        answerPopup.theme = theme
        answerPopup.theme.popupStyle = CNPPopupStyle.Centered
        answerPopup.delegate = nil
        answerPopup.presentPopupControllerAnimated(true)
    }
    
    private func unknownError() {
        print("unknown error")
        FIRAnalytics.logEventWithName("unknownError", parameters: [:])
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

        
        let sad = UIImageView(image: UIImage.gifWithName("cry"))
        
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
        FIRAnalytics.logEventWithName("couldntAnswerQuestion", parameters: [:])
        showError("Couldn't answer that!")
    }
    
    private func showAnsweringViewController() {
        let screenWidth = UIScreen.mainScreen().bounds.width

        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let gif = UIImageView(image: UIImage.gifWithName("think"))
        gif.frame = CGRect(x: 0, y: 0, width: w * 0.75, height: w * 0.75)
        
        let space = UIView()
        space.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        
        theme.cornerRadius = Radius.standardCornerRadius
        theme.backgroundColor = UIColor.solvelyPrimaryBlue()
        
        answeringPopup = CNPPopupController(contents:[gif, space])
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
        FIRAnalytics.logEventWithName("beginCrop", parameters: [:])
        self.crop(capturedImage.fullImage)
    }
}


extension HomeViewController: TOCropViewControllerDelegate {
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int) {
        FIRAnalytics.logEventWithName("finishCrop", parameters: [:])
        
        self.dismissViewControllerAnimated(true, completion: { [weak self] in
            self!.showAnsweringViewController()
            self!.convertImageToText(image)
        })
        
    }
}