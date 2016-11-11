//
//  Presenter.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

protocol Presenter {
    func processImage(image: UIImage!)
    func edit(text: String!)
    func solve(question: String!)
}

class BasePresenter<S: Strategy>: Presenter {
    weak var viewController: HomeViewController!
    var strategy: S!
    var disposeBag: DisposeBag!
    
    init(viewController: HomeViewController, strategy: S, disposeBag: DisposeBag) {
        self.viewController = viewController
        self.strategy = strategy
        self.disposeBag = disposeBag
    }
    
    func showLoadingPopUp() {
        let loadingPopUp = AnsweringPopUp.create()
        viewController.presentPopup(popup: loadingPopUp)
    }
    
    func processImage(image: UIImage!) {
        showLoadingPopUp()
        
        strategy.convertImageToText(image: image)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { text in
                self.processImageDidFinish(text: text, error: nil)
            }, onError: { error in
                self.solveQuestionDidFinish(answer: nil, error: error)
            }).addDisposableTo(disposeBag)
    }
    
    func showErrorPopUp(message: String! = "An error has occurred.") {
        let errorPopUp = ErrorPopUp.create(message: message, closeable: true) { [weak self] cl in
            self?.viewController.hideCurrentPopup()
        }
        
        viewController.presentPopup(popup: errorPopUp)
    }
    
    func edit(text: String!) {
        
    }
    
    func solve(question: String!) {
        showLoadingPopUp()
        
        strategy.solve(input: question)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { answer in
                self.solveQuestionDidFinish(answer: answer, error: nil)
            }, onError: { error in
                self.solveQuestionDidFinish(answer: nil, error: error)
            }).addDisposableTo(disposeBag)
    }
    
    func solveQuestionDidFinish(answer: StrategyResult?, error: Error?) { }
    func processImageDidFinish(text: String?, error: Error?) { }
}
