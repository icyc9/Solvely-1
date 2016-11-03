
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

class HomeViewController: UIViewController, UITextViewDelegate {
    private let hasSolvedKey = "hasSolved"
    private let reachabilityService = ReachabilityService()
    
    private var camera: FastttCamera!
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    private var cropBox: CropBoxView!
    
    var currentPopup: CNPPopupController!
    
    var connectionErrorShowing = false
    var popupBeforeConnectionError: CNPPopupController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //camera = FastttCamera()
        //camera.delegate = self
        //self.view.addSubview(camera.view)
        
        let squid = UIButton(type: .custom)
        
        if let image = UIImage(named: "squid top") {
            squid.setImage(image, for: .normal)
            let sw = image.size.width / 2
            let sh = image.size.height / 2
            squid.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - (sw / 2), y: UIScreen.main.bounds.height - sh + 5, width: sw, height: sh)
        }
        
        squid.addTarget(self, action: #selector(HomeViewController.takePicture), for: .touchUpInside)
        
        self.view.addSubview(squid)
        
        // Parent view should extend from top of screen to top of squid head
        let cropBoxParent = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - squid.frame.height))
        
        let cropBoxWidth = CGFloat(cropBoxParent.frame.width)
        let cropBoxHeight = CGFloat(cropBoxParent.frame.height / 3)
        
        cropBox = CropBoxView(frame: CGRect(x: 0, y: (cropBoxParent.frame.midY) - (cropBoxHeight / 2) , width: cropBoxWidth, height: cropBoxHeight / 3))
        
        cropBoxParent.addSubview(cropBox)
        view.addSubview(cropBoxParent)
        
        let help = UIButton(type: .custom)
        
        if let image = UIImage(named: "help") {
            help.setImage(image, for: .normal)
            let hw = image.size.width
            let hh = image.size.height
            help.frame = CGRect(x: UIScreen.main.bounds.width - hw - 8, y: UIScreen.main.bounds.height - hh - 8, width: hw, height: hh)
            help.addTarget(self, action: #selector(HomeViewController.showHelp), for: .touchUpInside)
        }
        
        self.view.addSubview(help)
        
        //self.setupActionSelector()
    }
    
    private func setupActionSelector() {
        let w = self.view.frame.width
        let h: CGFloat = self.view.frame.height / 2
        let x = (UIScreen.main.bounds.width / 2) - (w / 2)
        let y: CGFloat = 0
        let methodTableView = MethodSelectionTableView(frame: CGRect(x: x, y: y, width: w, height: h))
        
        view.addSubview(methodTableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
   
    func cropToBox(screenshot: UIImage) -> UIImage {
        let x = cropBox.bounds.minX / self.view.frame.width
        let y = cropBox.bounds.minY / self.view.frame.height
        let w = cropBox.bounds.width / self.view.frame.width
        let h = cropBox.bounds.height / self.view.frame.height
        
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
            self.cropBox.alpha = 1
        })
    }
    
    func presentPopup(popup: CNPPopupController) {
        UIView.animate(withDuration: 0.3, animations: {
            self.cropBox.alpha = 0
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
        currentPopup = EditQuestionPopUp.create(questionText: text ?? "", delegate: self)
        presentPopup(popup: currentPopup)
    }

    func showError(message: String! = "Something went wrong!", closeable: Bool! = true, handler: SelectionHandler?) {
        currentPopup = ErrorPopUp.create(message: message, closeable: closeable, handler: handler)
        self.presentPopup(popup: currentPopup)
    }

    func unableToAnswerQuestion() {
        showError(message: "Couldn't answer that!", closeable: true) {(button: CNPPopupButton!) -> Void in
            self.hidePopup(popup: self.currentPopup)
        }
    }
    
    func showAnsweringPopup() {
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

extension HomeViewController: ReachabilityServiceDelegate {
    
    func reachabilityChanged(connectionAvailable: Bool!) {
        
    }
}

extension HomeViewController: EditQuestionPopUpDelegate {
    
    func didPressSolve(editedQuestion: String!) {
        showAnsweringPopup()
        solve(question: editedQuestion)
    }
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
