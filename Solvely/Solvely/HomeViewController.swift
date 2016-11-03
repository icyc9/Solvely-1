
//
//  HomeViewController.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import FastttCamera
import RxSwift
import NMPopUpViewSwift
import CNPPopupController
import MessageUI
import ReachabilitySwift

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
    
    let reachability = Reachability()!
    var connectionErrorShowing = false
    var popupBeforeConnectionError: CNPPopupController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gcamera = FastttCamera()
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
        
        // Parent view should extend from top of screen to top of squid head
        let crosshairParent = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - squid.frame.height))
        
        crosshairW = CGFloat(crosshairParent.frame.width)
        crosshairH = CGFloat(crosshairParent.frame.height / 3)
        crosshairX = CGFloat((crosshairParent.frame.width / 2 ) - (crosshairParent.frame.width / 2))
        crosshairY = CGFloat((crosshairParent.frame.height / 2) - (crosshairParent.frame.height / 2))
        
        crosshair = CropBoxView(frame: CGRect(x: 0, y: (crosshairParent.frame.midY) - (crosshairH / 2) , width: crosshairW, height: crosshairH))
        
        crosshairParent.addSubview(crosshair)
        view.addSubview(crosshairParent)
        
        let help = UIButton(type: .custom)
        
        if let image = UIImage(named: "help") {
            help.setImage(image, for: .normal)
            let hw = image.size.width
            let hh = image.size.height
            help.frame = CGRect(x: screenWidth - hw - 8, y: screenHeight - hh - 8, width: hw, height: hh)
            help.addTarget(self, action: #selector(HomeViewController.showHelp), for: .touchUpInside)
        }
        
        self.view.addSubview(help)
        
        self.setupActionSelector()
        
        configureReachability()
    }
    
    private func setupActionSelector() {
        let w = self.view.frame.width
        let h: CGFloat = self.view.frame.height / 2
        let x = (UIScreen.main.bounds.width / 2) - (w / 2)
        let y: CGFloat = 0
        let methodTableView = MethodSelectionTableView(frame: CGRect(x: x, y: y, width: w, height: h))
        
        view.addSubview(methodTableView)
    }
    
    private func configureReachability() {
        reachability.whenReachable = { reachability in
            // this is called on a background thread
            DispatchQueue.main.async {
                if self.connectionErrorShowing {
                    self.currentPopup.dismiss(animated: true)
                    
                    // Reshow the popup from before the connection error
                    if self.popupBeforeConnectionError != nil {
                        self.currentPopup = self.popupBeforeConnectionError
                        self.popupBeforeConnectionError?.present(animated: true)
                    }
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread
            DispatchQueue.main.async {
                self.connectionErrorShowing = true
                self.popupBeforeConnectionError = self.currentPopup
                
                if self.popupBeforeConnectionError != nil {
                    self.popupBeforeConnectionError?.dismiss(animated: true)
                }
                
                self.showError(message: "Solvely can't help you without an internet connection!", closeable: false, closeHandler: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.showGrowthHack()
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
        currentPopup = HelpPopUp.create(delegate: self)
        presentPopup(popup: currentPopup)
    }
    
    func hidePopup(popup: CNPPopupController) {
        currentPopup.dismiss(animated: true)
        UIView.animate(withDuration: 0.3, animations: {
            self.crosshair.alpha = 1
        })
    }
    
    func presentPopup(popup: CNPPopupController) {
        UIView.animate(withDuration: 0.3, animations: {
            self.crosshair.alpha = 0
        })
        
        popup.present(animated: true)
    }
    
    func showAnswer(answer: Answer?) {
        currentPopup = AnswerPopUp.create(answer: answer, delegate: self)
        self.presentPopup(popup: currentPopup)
    }
    
    func showGrowthHack() {
        
    }
    
    func showThanksForSharing() {
        
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
            self.showError(message: "It seems like your device can't send text messages!", closeable: true) {(button: CNPPopupButton!) -> Void in
                self.currentPopup.dismiss(animated: true)
                self.showGrowthHack()
            }
        }
    }
    
    func couldntReadThat() {
        showError(message: "Couldn't read that!", closeable: true) {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
    }
    
    func unknownError() {
        print("unknown error")
        showError(message: "Something went wrong!", closeable: true) {(button: CNPPopupButton!) -> Void in
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

    func showError(message: String?, closeable: DarwinBoolean?, closeHandler: SelectionHandler?) {
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
        
        var contents = [topPaddingView, sad, somethingWentWrong]
        
        if closeable == true {
            let close = CNPPopupButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
            close.setTitleColor(UIColor.solvelyPrimaryBlue(), for: .normal)
            close.titleLabel!.font = UIFont(name: "Raleway", size: 24)
            close.setTitle("Close", for: .normal)
            close.backgroundColor = UIColor.white
            close.layer.cornerRadius = Radius.standardCornerRadius
            close.selectionHandler = closeHandler
            
            contents.append(close)
        }
        
        contents.append(paddingView)
        
        currentPopup = CNPPopupController(contents: contents)
        currentPopup.theme = theme
        currentPopup.theme.popupStyle = CNPPopupStyle.centered
        currentPopup.delegate = nil
        
        self.presentPopup(popup: currentPopup)
    }
    
    func unableToAnswerQuestion() {
        showError(message: "Couldn't answer that!", closeable: true) {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
    }
    
    func showAnsweringViewController() {
        currentPopup = AnsweringPopUp.create()
        presentPopup(popup: currentPopup)
    }
    
    func showTranslatePopup() {
        
    }
    
    func pad(vert: CGFloat = 8) -> UIView {
        let paddingView = UIView()
        paddingView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: vert)
        return paddingView
    }
}

extension HomeViewController {
    
}

extension HomeViewController: SolvelyPopUpDelegate {
    
    func popUpDidClose() {
        self.hidePopup(popup: currentPopup)
    }
}

extension HomeViewController: FastttCameraDelegate {
    
    func cameraController(_ cameraController: FastttCameraInterface!, didFinishCapturing capturedImage: FastttCapturedImage!) {
        print(capturedImage.fullImage.size)
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
            self.showError(message: "Looks like your text message failed to send! Try again.", closeable: true) {(button: CNPPopupButton!) -> Void in
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
