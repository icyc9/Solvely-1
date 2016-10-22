
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
import MessageUI

class HomeViewController: UIViewController, UITextViewDelegate {
    private let hasSolvedKey = "hasSolved"
    
    private var camera: FastttCamera!
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    private var crosshair: UIView!
    
    var currentPopup: CNPPopupController!
    
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
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        self.view.addSubview(camera.view)
        
        let squid = UIButton(type: .custom)
        
        if let image = UIImage(named: "squid top") {
            squid.setImage(image, for: .normal)
            let sw = image.size.width / 2
            let sh = image.size.height / 2
            squid.frame = CGRect(x: (screenWidth / 2) - (sw / 2), y: screenHeight - sh + 5, width: sw, height: sh)
        }
        
        squid.addTarget(self, action: #selector(HomeViewController.takePicture), for: .touchUpInside)
        
        self.view.addSubview(squid)
        
        crosshairW = CGFloat(screenWidth)
        crosshairH = CGFloat(screenHeight / 3)
        crosshairX = CGFloat((screenWidth / 2 ) - (crosshairW / 2))
        crosshairY = CGFloat((screenHeight / 2) - (crosshairH / 2))
        
        crosshair = UIView(frame: CGRect(x: crosshairX, y: crosshairY, width: crosshairW, height: crosshairH))
        crosshair.isUserInteractionEnabled = false
        
        crosshair.backgroundColor = UIColor(red: 0.9333, green: 0.9333, blue: 0.9333, alpha: 1.0).withAlphaComponent(0.4)
        
        self.view.addSubview(crosshair)
        
        let help = UIButton(type: .custom)
        
        if let image = UIImage(named: "help") {
            help.setImage(image, for: .normal)
            let hw = image.size.width
            let hh = image.size.height
            help.frame = CGRect(x: screenWidth - hw - 8, y: screenHeight - hh - 8, width: hw, height: hh)
            help.addTarget(self, action: #selector(HomeViewController.showHelp2), for: .touchUpInside)
        }
        
        self.view.addSubview(help)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.showGrowthHack()
//        if hasShownHelp == false {
//            hasShownHelp = true
//            self.showHelp2(nil)
//        }
        
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
    
    func crop(image: UIImage!) {
        let cropped = cropToBox(screenshot: image)
        
        let crop = TOCropViewController(image: cropped)
        crop.delegate = self
        self.present(crop, animated: true, completion: nil)
    }
    
    func cropToBox(screenshot: UIImage) -> UIImage {
        let x = crosshairX / self.view.frame.width
        let y = crosshairY / self.view.frame.height
        let w = crosshairW / self.view.frame.width
        let h = crosshairH / self.view.frame.height
        
        let cropped = CGRect(x: x * screenshot.size.width, y: y * screenshot.size.height, width: w * screenshot.size.width, height: h * screenshot.size.height)
        
        print(cropped)
        let cgImage = screenshot.cgImage!.cropping(to: cropped)
        let image: UIImage = UIImage(cgImage: cgImage!)
        return image
    }
    
    func convertImageToText(image: UIImage!) {
        self.ocrService.convertImageToText(image: image)
            .observeOn(MainScheduler.instance)
            //.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS.background))
            .subscribe(onNext: { (text) in
                if text != nil && text != "" {
                    print(text!)
                    self.hidePopup(popup: self.currentPopup)
                    self.showEdit(text: text!)
                }
                else {
                    self.hidePopup(popup: self.currentPopup)
                    self.couldntReadThat()
                }
            }, onError: { (error) in
                print(error)
                self.hidePopup(popup: self.currentPopup)
                self.unknownError()
            }, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(self.disposeBag)
    }
    
    func takePicture(sender: UIButton?) {
        camera.takePicture()
    }
    
    func solve(question: String) {
        solveService.solveQuestion(question: question)
            .observeOn(MainScheduler.instance)
            //.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: { (answer) in
                self.hidePopup(popup: self.currentPopup)
                    
                if answer != nil {
                    self.showAnswer(answer: answer)
                }
                else {
                    self.unableToAnswerQuestion()
                }
            }, onError: { (error) in
                self.hidePopup(popup: self.currentPopup)
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
        let close = CNPPopupButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Got it!", for: .normal)
        close.backgroundColor = UIColor.white
        close.layer.cornerRadius = Radius.standardCornerRadius
        
        
        let screenWidth = UIScreen.main.bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let gif = UIImageView(image: UIImage.gifWithName(name: "think"))
        gif.contentMode = .scaleAspectFit
        gif.frame = CGRect(x: w / 2, y: y, width: w / 2, height: w / 2)
        
        let message = UILabel()
        message.textColor = UIColor.white
        message.font = UIFont(name: "Raleway", size: 17)
        message.numberOfLines = 0
        message.textAlignment = NSTextAlignment.center
        message.lineBreakMode = NSLineBreakMode.byWordWrapping
        message.text = "Hey, I'm Solvely the squid!\n Fit your question in the white box and then tap my head on the bottom of the screen to get your answer!"
        message.textAlignment = NSTextAlignment.center;
        message.frame = CGRect(x: 0, y: 0, width: screenWidth - 40 - 20, height: 100)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(popupAlpha)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        currentPopup = CNPPopupController(contents:[gif, message, paddingView2, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
        
        self.presentPopup(popup: currentPopup)
    }

    
    func showHelp2(sender: UIButton?) {
        let close = CNPPopupButton(frame: CGRect(x: 0, y:0, width: 150, height: 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Got it!", for: .normal)
        close.backgroundColor = UIColor.white
        close.layer.cornerRadius = Radius.standardCornerRadius
        
        
        let screenWidth = UIScreen.main.bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        let y = CGFloat((h / 2))
        
        let gif = UIImageView(image: UIImage.gifWithName(name: "think"))
        gif.contentMode = .scaleAspectFit
        gif.frame = CGRect(x: w / 2, y: y, width: w / 2, height: w / 2)
        
        let topTitle = UILabel()
        topTitle.textColor = UIColor.white
        topTitle.font = UIFont(name: "Raleway-Bold", size: 17)
        topTitle.numberOfLines = 0
        topTitle.textAlignment = NSTextAlignment.center
        topTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        topTitle.text = "** multiple choice questions only **"
        topTitle.textAlignment = NSTextAlignment.center;
        topTitle.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 75)
        
        let bottomTitle = UILabel()
        bottomTitle.textColor = UIColor.white
        bottomTitle.font = UIFont(name: "Raleway-Bold", size: 17)
        bottomTitle.numberOfLines = 0
        bottomTitle.textAlignment = NSTextAlignment.center
        bottomTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        bottomTitle.text = "Solvely was created by two high school juniors. Don't expect perfect accuracy."
        bottomTitle.textAlignment = NSTextAlignment.center;
        bottomTitle.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 75)
        
        let title = UILabel()
        title.textColor = UIColor.white
        title.font = UIFont(name: "Raleway-Bold", size: 21)
        title.numberOfLines = 0
        title.textAlignment = NSTextAlignment.center
        title.lineBreakMode = NSLineBreakMode.byWordWrapping
        title.text = "Works well on"
        title.textAlignment = NSTextAlignment.center;
        title.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 20)
        
        let message = UILabel()
        message.textColor = UIColor.white
        message.font = UIFont(name: "Raleway", size: 17)
        message.numberOfLines = 0
        message.textAlignment = NSTextAlignment.center
        message.lineBreakMode = NSLineBreakMode.byWordWrapping
        message.text = "Factual questions.\nMany subjects (stay simple).\nHistory questions."
        message.textAlignment = NSTextAlignment.center;
        message.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 75)
        
        
        let title2 = UILabel()
        title2.textColor = UIColor.white
        title2.font = UIFont(name: "Raleway-Bold", size: 21)
        title2.numberOfLines = 0
        title2.textAlignment = NSTextAlignment.center
        title2.lineBreakMode = NSLineBreakMode.byWordWrapping
        title2.text = "Doesn't work on"
        title2.textAlignment = NSTextAlignment.center;
        title2.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 20)
        
        let message2 = UILabel()
        message2.textColor = UIColor.white
        message2.font = UIFont(name: "Raleway", size: 17)
        message2.numberOfLines = 0
        message2.textAlignment = NSTextAlignment.center
        message2.lineBreakMode = NSLineBreakMode.byWordWrapping
        message2.text = "Math.\nWord problems.\nQuestions on reading passages.\nQuestions requiring critical thought."
        message2.textAlignment = NSTextAlignment.center;
        message2.frame = CGRect(x: 0, y: 0, width: screenWidth - 16, height: 100)
        
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
        
        currentPopup = CNPPopupController(contents:[paddingView4, topTitle, paddingView6, title, message, paddingView3, title2, message2, paddingView5, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
        
        self.presentPopup(popup: currentPopup)
    }
    
    func hidePopup(popup: CNPPopupController) {
        UIView.animate(withDuration: 0.3, animations: {
            self.crosshair.alpha = 1
        })
        
        popup.dismiss(animated: true)
    }
    
    func presentPopup(popup: CNPPopupController) {
        UIView.animate(withDuration: 0.3, animations: {
            self.crosshair.alpha = 0
        })
        
        popup.present(animated: true)
    }
    
    func showAnswer(answer: Answer?) {
        let screenWidth = UIScreen.main.bounds.width
        
        let w = CGFloat(screenWidth)
        
        let title = UILabel()
        title.textColor = UIColor.white
        title.font = UIFont(name: "Raleway", size: 18)
        title.text = "the answer may be"
        title.textAlignment = NSTextAlignment.center;
        title.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        let disclaimer = UILabel()
        disclaimer.textColor = UIColor.white
        disclaimer.numberOfLines = 0
        disclaimer.lineBreakMode = NSLineBreakMode.byTruncatingTail
        disclaimer.font = UIFont(name: "Raleway", size: 14)
        disclaimer.text = "This is a beta. There's always a chance that Solvely's answer is wrong. We are working to improve Solvely's accuracy every day."
        disclaimer.textAlignment = NSTextAlignment.center;
        disclaimer.frame = CGRect(x: 0, y: 0, width: w - 16, height: 50)
        
        let answerLetter = UILabel()
        answerLetter.textColor = UIColor.white
        answerLetter.font = UIFont(name: "Raleway", size: 72)
        
        var identifier = ""
        
        if answer?.identifier != nil {
            identifier = (answer?.identifier)!
        }
        
        answerLetter.text = identifier.uppercased()
        answerLetter.textAlignment = NSTextAlignment.center;
        answerLetter.frame = CGRect(x: 0, y: 0, width: w, height: 58)
        
        let answerText = UILabel()
        answerText.lineBreakMode = NSLineBreakMode.byTruncatingTail
        answerText.textColor = UIColor.white
        answerText.font = UIFont(name: "Raleway", size: 24)
        answerText.text = answer?.text ?? ""
        answerText.textAlignment = NSTextAlignment.center;
        answerText.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        let close = CNPPopupButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Ok", for: .normal)
        close.backgroundColor = UIColor.white
        close.layer.cornerRadius = Radius.standardCornerRadius
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
        
        let topPaddingView = UIView()
        topPaddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: w, height: 24)
        
        let paddingView3 = UIView()
        paddingView3.frame = CGRect(x: 0, y: 0, width: w, height: 8)
    
        let paddingView4 = UIView()
        paddingView4.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView5 = UIView()
        paddingView5.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, title, paddingView3, answerLetter, answerText, paddingView2, disclaimer, paddingView5, close, paddingView4, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        
        self.presentPopup(popup: currentPopup)
    }
    
    func showGrowthHack() {
        let screenWidth = UIScreen.main.bounds.width
        
        let w = CGFloat(screenWidth)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(popupAlpha)
        
        let topPaddingView = UIView()
        topPaddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)

        let paddingView1 = UIView()
        paddingView1.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView2 = UIView()
        paddingView2.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let message = UILabel()
        message.textColor = UIColor.white
        message.numberOfLines = 0
        message.lineBreakMode = .byWordWrapping
        message.font = UIFont(name: "Raleway", size: 17)
        message.text = "If you want unlimited solves, you must share Solvely with a friend!"
        message.textAlignment = NSTextAlignment.center;
        message.frame = CGRect(x: 0, y: 0, width: w, height: 100)
        
        let sendMessageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        sendMessageButton.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        sendMessageButton.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        sendMessageButton.setTitle("Text a friend", for: .normal)
        sendMessageButton.backgroundColor = UIColor.white
        sendMessageButton.layer.cornerRadius = Radius.standardCornerRadius
        sendMessageButton.addTarget(self, action: #selector(HomeViewController.sendSMSMessage), for: .touchUpInside)
        
        let sendTweetButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        sendTweetButton.setTitleColor(UIColor.white, for: .normal)
        sendTweetButton.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        sendTweetButton.setTitle("Tweet", for: .normal)
        sendTweetButton.backgroundColor = UIColor.solvelyPrimaryBlue()
        sendTweetButton.layer.cornerRadius = Radius.standardCornerRadius
        sendTweetButton.addTarget(self, action: #selector(HomeViewController.retakePicture), for: .touchUpInside)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, message, paddingView1, sendMessageButton, paddingView2, sendTweetButton, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        
        self.presentPopup(popup: currentPopup)
    }
    
    func showThanksForSharing() {
        let screenWidth = UIScreen.main.bounds.width
        
        let w = CGFloat(screenWidth)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(popupAlpha)
        
        let topPaddingView = UIView()
        topPaddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView1 = UIView()
        paddingView1.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let message = UILabel()
        message.textColor = UIColor.white
        message.numberOfLines = 0
        message.lineBreakMode = .byWordWrapping
        message.font = UIFont(name: "Raleway", size: 17)
        message.text = "Thanks for sharing Solvely! You now have unlimited solves!"
        message.textAlignment = NSTextAlignment.center;
        message.frame = CGRect(x: 0, y: 0, width: w, height: 100)
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        closeButton.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        closeButton.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        closeButton.setTitle("Get Solvin'", for: .normal)
        closeButton.backgroundColor = UIColor.white
        closeButton.layer.cornerRadius = Radius.standardCornerRadius
        closeButton.addTarget(self, action: #selector(HomeViewController.sendSMSMessage), for: .touchUpInside)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, message, paddingView1, closeButton, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        
        self.presentPopup(popup: currentPopup)
    }
    
    func sendSMSMessage(sender: UIButton?) {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
        
            composeVC.recipients = ["7033623714"]
            composeVC.body = "This app Solvely lets you take a picture of a multiple choice question and receive the answer. Check it out at http://apple.co/2bMVIKY"
        
            self.present(composeVC, animated: true, completion: nil)
        }
        else {
            self.hidePopup(popup: self.currentPopup)
            self.showError(message: "It seems like your device can't send text messages!") {(button: CNPPopupButton!) -> Void in
                self.currentPopup.dismiss(animated: true)
                self.showGrowthHack()
            }
        }
    }
    
    func couldntReadThat() {
        showError(message: "Couldn't read that!") {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
    }
    
    func unknownError() {
        print("unknown error")
        showError(message: "Something went wrong!") {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
    }
    
    
    func showEdit(text: String?) {
        self.hidePopup(popup: self.currentPopup)
        
        let screenWidth = UIScreen.main.bounds.width
        
        let w = CGFloat(screenWidth)
        
        
        let title = UILabel()
        title.textColor = UIColor.white
        title.font = UIFont(name: "Raleway", size: 17)
        title.text = "Edit your question"
        title.textAlignment = NSTextAlignment.center;
        title.frame = CGRect(x: 0, y: 0, width: w, height: 50)
        
        editQuestionTextView = UITextView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: UIScreen.main.bounds.height / 3))
        editQuestionTextView.font = UIFont(name: "Raleway", size: 17)
        editQuestionTextView.text = text
        editQuestionTextView.makeRounded()
        
        let close = CNPPopupButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Solve", for: .normal)
        close.backgroundColor = UIColor.white
        close.layer.cornerRadius = Radius.standardCornerRadius

        let retake = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        retake.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        retake.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        retake.setTitle("Retake", for: .normal)
        retake.backgroundColor = UIColor.white
        retake.layer.cornerRadius = Radius.standardCornerRadius
        retake.addTarget(self, action: #selector(HomeViewController.retakePicture), for: .touchUpInside)
        
        let paddingView4 = UIView()
        paddingView4.frame = CGRect(x: 0, y: 0, width: w, height: 8)

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
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, title, editQuestionTextView!, paddingView2, retake, paddingView4, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        self.presentPopup(popup: currentPopup)
        
        close.selectionHandler = {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
            self.showAnsweringViewController()
            self.solve(question: self.editQuestionTextView.text)
        }
        
        let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(HomeViewController.doneEditingQuestion))
        doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 17)!], for: UIControlState.normal)
        doneButton.tintColor = UIColor.solvelyPrimaryBlue()
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        keyboardToolbar.barTintColor = UIColor.white
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barStyle = UIBarStyle.default
        keyboardToolbar.setItems([flexButton, doneButton], animated: true)
        keyboardToolbar.sizeToFit()
        editQuestionTextView.inputAccessoryView = keyboardToolbar
    }
    
    func retakePicture() {
        hidePopup(popup: currentPopup)
    }
    
    func doneEditingQuestion() {
        if editQuestionTextView != nil {
            editQuestionTextView!.endEditing(true)
        }
    }

    func showError(message: String?, closeHandler: SelectionHandler?) {
        let screenWidth = UIScreen.main.bounds.width
        
        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        _ = CGFloat((h / 2))
        
        let somethingWentWrong = UILabel()
        somethingWentWrong.textColor = UIColor.white
        somethingWentWrong.font = UIFont(name: "Raleway", size: 18)
        somethingWentWrong.text = message
        somethingWentWrong.lineBreakMode = .byWordWrapping
        somethingWentWrong.numberOfLines = 0
        somethingWentWrong.textAlignment = NSTextAlignment.center;
        somethingWentWrong.frame = CGRect(x: 0, y: 0, width: w, height: 100)
        
        let close = CNPPopupButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        close.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
        close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
        close.setTitle("Close", for: .normal)
        close.backgroundColor = UIColor.white
        close.layer.cornerRadius = Radius.standardCornerRadius
        close.selectionHandler = closeHandler
        
        
        let sad = UIImageView(image: UIImage.gifWithName(name: "cry"))
        
        sad.frame = CGRect(x: w / 2, y: 0, width: w / 2, height: w / 2)
        sad.contentMode = .scaleAspectFit
        
        let topPaddingView = UIView()
        topPaddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: w, height: 8)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[topPaddingView, sad, somethingWentWrong, close, paddingView])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        self.presentPopup(popup: currentPopup)
    }
    
    func unableToAnswerQuestion() {
        showError(message: "Couldn't answer that!") {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
    }
    
    func showAnsweringViewController() {
        let screenWidth = UIScreen.main.bounds.width

        let w = CGFloat(screenWidth)
        let h = CGFloat(w)
        _ = CGFloat((h / 2))
        
        let gif = UIImageView(image: UIImage.gifWithName(name: "think"))
        gif.frame = CGRect(x: 0, y: 0, width: w * 0.75, height: w * 0.75)
        
        let space = UIView()
        space.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        
        let theme = CNPPopupTheme()
        theme.maxPopupWidth = screenWidth
        theme.backgroundColor = UIColor.solvelyPrimaryBlue().withAlphaComponent(popupAlpha)
        
        currentPopup = CNPPopupController(contents:[gif, space])
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        self.presentPopup(popup: currentPopup)
    }
    
    func removeViewControllerFromContainer(controller: UIViewController?) {
        controller?.removeFromParentViewController()
        controller?.view.removeFromSuperview()
    }
}

extension HomeViewController: FastttCameraDelegate {
    
    func cameraController(cameraController: FastttCameraInterface!, didFinishNormalizingCapturedImage capturedImage: FastttCapturedImage!) {
        self.crop(image: capturedImage.fullImage)
    }
}


extension HomeViewController: TOCropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        self.dismiss(animated: true, completion: { [weak self] in
            self!.showAnsweringViewController()
            self!.convertImageToText(image: image)
        })
        
    }
}

extension HomeViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            self.showGrowthHack()
            break
        case is MessageComposeResult:
            self.hidePopup(popup: self.currentPopup)
            self.showError(message: "Looks like your text message failed to send! Try again.") {(button: CNPPopupButton!) -> Void in
                self.currentPopup.dismiss(animated: true)
                self.showGrowthHack()
            }
            break
        case is MessageComposeResult:
            self.showThanksForSharing()
            break
        default:
            break
        }
    }
}
