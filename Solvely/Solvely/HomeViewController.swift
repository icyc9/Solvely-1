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

class HomeViewController: UIViewController, UITextViewDelegate {
    private let hasSolvedKey = "hasSolved"
    
    private var camera: FastttCamera!
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    private var crosshair: UIView!
    
    private var currentPopup: CNPPopupController!
    
    private var crosshairX: CGFloat = 0
    private var crosshairY: CGFloat = 0
    private var crosshairW: CGFloat = 0
    private var crosshairH: CGFloat = 0
    private let popupAlpha: CGFloat = 0.75
    private var editQuestionTextView: UITextView!
    
    private var hasShownHelp = false
    
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
        
        crosshairW = CGFloat(screenWidth)
        crosshairH = CGFloat(screenHeight / 3)
        crosshairX = CGFloat((screenWidth / 2 ) - (crosshairW / 2))
        crosshairY = CGFloat((screenHeight / 2) - (crosshairH / 2))
        
        crosshair = UIView(frame: CGRect(x: crosshairX, y: crosshairY, width: crosshairW, height: crosshairH))
        crosshair.userInteractionEnabled = false
        
        crosshair.backgroundColor = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0).colorWithAlphaComponent(0.4)
        
        self.view.addSubview(crosshair)
        
        let help = UIButton(type: .Custom)
        
        if let image = UIImage(named: "help") {
            help.setImage(image, forState: .Normal)
            let hw = image.size.width
            let hh = image.size.height
            help.frame = CGRect(x: screenWidth - hw - 8, y: screenHeight - hh - 8, width: hw, height: hh)
            help.addTarget(self, action: #selector(HomeViewController.showHelp2), forControlEvents: .TouchUpInside)
        }
        
        self.view.addSubview(help)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if hasShownHelp == false {
            hasShownHelp = true
            self.showHelp2(nil)
        }
        
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let hasSolvedQuestion = defaults.valueForKey(hasSolvedKey) as? Bool
//        
//        if hasSolvedQuestion == nil || hasSolvedQuestion == false {
//            let defaults = NSUserDefaults.standardUserDefaults()
//            defaults.setObject(true, forKey: self.hasSolvedKey)
//            
//            showHelp(nil)
//        }
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
                    self.hidePopup(self.currentPopup)
                    self.showEdit(text!)
                }
                else {
                    self.hidePopup(self.currentPopup)
                    self.couldntReadThat()
                }
            }, onError: { (error) in
                print(error)
                self.hidePopup(self.currentPopup)
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
                self.hidePopup(self.currentPopup)
                    
                if answer != nil {
                    self.showAnswer(answer)
                }
                else {
                    self.unableToAnswerQuestion()
                }
            }, onError: { (error) in
                self.hidePopup(self.currentPopup)
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
        let close = CNPPopupButton(frame: CGRectMake(0, 0, 150, 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), forState: .Normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Got it!", forState: .Normal)
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
        message.text = "Hey, I'm Solvely the squid!\n Fit your question in the white box and then tap my head on the bottom of the screen to get your answer!"
        message.textAlignment = NSTextAlignment.Center;
        message.frame = CGRect(x: 0, y: 0, width: screenWidth - 40 - 20, height: 100)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().colorWithAlphaComponent(popupAlpha)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        currentPopup = CNPPopupController(contents:[gif, message, paddingView2, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.Centered
        currentPopup.delegate = nil
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.hidePopup(self.currentPopup)
        }
        
        self.presentPopup(currentPopup)
    }

    
    func showHelp2(sender: UIButton?) {
        let close = CNPPopupButton(frame: CGRectMake(0, 0, 150, 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), forState: .Normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Got it!", forState: .Normal)
        close.backgroundColor = UIColor.whiteColor()
        close.layer.cornerRadius = Radius.standardCornerRadius
        
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let gif = UIImageView(image: UIImage.gifWithName("think"))
        gif.contentMode = .ScaleAspectFit
        gif.frame = CGRect(x: w / 2, y: y, width: w / 2, height: w / 2)
        
        let topTitle = UILabel()
        topTitle.textColor = UIColor.whiteColor()
        topTitle.font = UIFont(name: "Raleway-Bold", size: 17)
        topTitle.numberOfLines = 0
        topTitle.textAlignment = NSTextAlignment.Center
        topTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        topTitle.text = "** multiple choice questions only **"
        topTitle.textAlignment = NSTextAlignment.Center;
        topTitle.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 75)
        
        let bottomTitle = UILabel()
        bottomTitle.textColor = UIColor.whiteColor()
        bottomTitle.font = UIFont(name: "Raleway-Bold", size: 17)
        bottomTitle.numberOfLines = 0
        bottomTitle.textAlignment = NSTextAlignment.Center
        bottomTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        bottomTitle.text = "Solvely was created by two high school juniors. Don't expect perfect accuracy."
        bottomTitle.textAlignment = NSTextAlignment.Center;
        bottomTitle.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 75)
        
        let title = UILabel()
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "Raleway-Bold", size: 21)
        title.numberOfLines = 0
        title.textAlignment = NSTextAlignment.Center
        title.lineBreakMode = NSLineBreakMode.ByWordWrapping
        title.text = "Works well on"
        title.textAlignment = NSTextAlignment.Center;
        title.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 20)
        
        let message = UILabel()
        message.textColor = UIColor.whiteColor()
        message.font = UIFont(name: "Raleway", size: 17)
        message.numberOfLines = 0
        message.textAlignment = NSTextAlignment.Center
        message.lineBreakMode = NSLineBreakMode.ByWordWrapping
        message.text = "Factual questions.\nMany subjects (stay simple).\nHistory questions."
        message.textAlignment = NSTextAlignment.Center;
        message.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 75)
        
        
        let title2 = UILabel()
        title2.textColor = UIColor.whiteColor()
        title2.font = UIFont(name: "Raleway-Bold", size: 21)
        title2.numberOfLines = 0
        title2.textAlignment = NSTextAlignment.Center
        title2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        title2.text = "Doesn't work on"
        title2.textAlignment = NSTextAlignment.Center;
        title2.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 20)
        
        let message2 = UILabel()
        message2.textColor = UIColor.whiteColor()
        message2.font = UIFont(name: "Raleway", size: 17)
        message2.numberOfLines = 0
        message2.textAlignment = NSTextAlignment.Center
        message2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        message2.text = "Math.\nWord problems.\nQuestions requiring critical thought."
        message2.textAlignment = NSTextAlignment.Center;
        message2.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 75)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue()
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 16)
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView3 = UIView()
        paddingView3.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView4 = UIView()
        paddingView4.frame = CGRect(x: 0, y: 0, width: w, height: 16)
        
        let paddingView5 = UIView()
        paddingView5.frame = CGRect(x: 0, y: 0, width: w, height: 8)
   
        let paddingView6 = UIView()
        paddingView6.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        currentPopup = CNPPopupController(contents:[paddingView4, topTitle, paddingView6, title, message, paddingView3, title2, message2, paddingView2, bottomTitle, paddingView5, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.Centered
        currentPopup.delegate = nil
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.hidePopup(self.currentPopup)
        }
        
        self.presentPopup(currentPopup)
    }
    
    private func hidePopup(popup: CNPPopupController) {
        UIView.animateWithDuration(0.3, animations: {
            self.crosshair.alpha = 1
        })
        
        popup.dismissPopupControllerAnimated(true)
    }
    
    private func presentPopup(popup: CNPPopupController) {
        UIView.animateWithDuration(0.3, animations: {
            self.crosshair.alpha = 0
        })
        
        popup.presentPopupControllerAnimated(true)
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
            self.hidePopup(self.currentPopup)
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
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().colorWithAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, title, paddingView3, answerLetter, answerText, paddingView2, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.Centered
        currentPopup.delegate = nil
        
        self.presentPopup(currentPopup)
    }
    
    private func couldntReadThat() {
        showError("Couldn't read that!")
    }
    
    private func unknownError() {
        print("unknown error")
        showError("Something went wrong!")
    }
    
    
    private func showEdit(text: String?) {
        self.hidePopup(self.currentPopup)
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        
        let title = UILabel()
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "Raleway", size: 17)
        title.text = "Edit your question"
        title.textAlignment = NSTextAlignment.Center;
        title.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        editQuestionTextView = UITextView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: UIScreen.mainScreen().bounds.height / 3))
        editQuestionTextView.font = UIFont(name: "Raleway", size: 17)
        editQuestionTextView.text = text
        editQuestionTextView.makeRounded()
        
        let close = CNPPopupButton(frame: CGRectMake(0, 0, 150, 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), forState: .Normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Solve", forState: .Normal)
        close.backgroundColor = UIColor.whiteColor()
        close.layer.cornerRadius = Radius.standardCornerRadius


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
        theme.movesAboveKeyboard = true
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().colorWithAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, title, editQuestionTextView!, paddingView2, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.Centered
        currentPopup.delegate = nil
        self.presentPopup(currentPopup)
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.hidePopup(self.currentPopup)
            self.showAnsweringViewController()
            self.solve(self.editQuestionTextView.text)
        }
        
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(HomeViewController.doneEditingQuestion))
        doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 17)!], forState: UIControlState.Normal)
        doneButton.tintColor = UIColor.solvelyPrimaryBlue()
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        keyboardToolbar.barTintColor = UIColor.whiteColor()
        keyboardToolbar.translucent = false
        keyboardToolbar.barStyle = UIBarStyle.Default
        keyboardToolbar.setItems([flexButton, doneButton], animated: true)
        keyboardToolbar.sizeToFit()
        editQuestionTextView.inputAccessoryView = keyboardToolbar
    }
    
    func doneEditingQuestion() {
        if editQuestionTextView != nil {
            editQuestionTextView!.endEditing(true)
        }
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
            self.hidePopup(self.currentPopup)
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
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().colorWithAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, sad, somethingWentWrong, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.Centered
        currentPopup.delegate = nil
        self.presentPopup(currentPopup)
    }
    
    private func unableToAnswerQuestion() {
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
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().colorWithAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[gif, space])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.Centered
        currentPopup.delegate = nil
        self.presentPopup(currentPopup)
    }
    
    private func removeViewControllerFromContainer(controller: UIViewController?) {
        controller?.removeFromParentViewController()
        controller?.view.removeFromSuperview()
    }
}

extension HomeViewController: FastttCameraDelegate {
    
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        self.crop(capturedImage.fullImage)
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