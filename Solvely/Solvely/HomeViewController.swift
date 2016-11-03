
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
    private let reachabilityService = ReachabilityService()
    private let solveService = SolveService()
    private let ocrService = OCRService()
    private let disposeBag = DisposeBag()
    
    var camera: FastttCamera!
    var cropBox: CropBoxView!
    
    var currentPopup: CNPPopupController!
    var connectionErrorShowing = false
    var popupBeforeConnectionError: CNPPopupController?
    
    var takePictureButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //camera = FastttCamera()
        //camera.delegate = self
        //self.view.addSubview(camera.view)
        
        addTakePictureButton()
        addCropBox()
        addHelpButton()
        addActionSelector()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
}
