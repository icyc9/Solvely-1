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

class BasePresenter: Presenter {
    weak var viewController: HomeViewController!
    var strategy: MultipleChoiceStrategy!
    var disposeBag: DisposeBag!
    
    init(viewController: HomeViewController, strategy: MultipleChoiceStrategy, disposeBag: DisposeBag) {
        self.viewController = viewController
        self.strategy = strategy
        self.disposeBag = disposeBag
    }
    
    func processImage(image: UIImage!) {
        strategy.convertImageToText(image: image)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { text in
                self.processImageDidFinish(text: text, error: nil)
            }, onError: { error in
                self.solveQuestionDidFinish(answer: nil, error: error)
            }).addDisposableTo(disposeBag)
    }
    
    func edit(text: String!) {
        
    }
    
    func solve(question: String!) {
        strategy.solve(input: question)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { answer in
                self.solveQuestionDidFinish(answer: answer, error: nil)
            }, onError: { error in
                self.solveQuestionDidFinish(answer: nil, error: error)
            }).addDisposableTo(disposeBag)
    }
    
    func solveQuestionDidFinish(answer: Answer?, error: Error?) { }
    func processImageDidFinish(text: String?, error: Error?) { }
}
