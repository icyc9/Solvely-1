//
//  HomeViewController+MultipleChoiceUI.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/3/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

extension HomeViewController {
    
    func showAnswer(answer: Answer!) {
        currentPopup = AnswerPopUp.create(answer: answer, delegate: self)
        presentPopup(popup: currentPopup)
    }
    
    
    
    func processImageForMultipleChoice(image: UIImage) {
        convertImageToText(image: image)
            //.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS.background))
            .subscribe(onNext: { [weak self] (text) in
                if text != nil && text != "" {
                    print(text!)
                    self?.hideCurrentPopup()
                    self?.showEdit(text: text!)
                }
                else {
                    self?.hideCurrentPopup()
                    self?.showError(message: "Couldn't read that. Make sure your picture is clear and has no handwriting!")
                }
            }, onError: { (error) in
                print(error)
                self.hideCurrentPopup()
                self.showError()
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
