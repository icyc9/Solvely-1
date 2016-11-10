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
    
    func solveMultipleChoice(question: String!) {
        solveService.solveQuestion(question: question)
            .observeOn(MainScheduler.instance)
            //.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .subscribe(onNext: { (answer) in
                self.hidePopup(popup: self.currentPopup)
                
                if answer != nil {
                    self.showAnswer(answer: answer)
                }
                else {
                    self.showError(message: "Can't answer that!")
                }
            }, onError: { (error) in
                self.hidePopup(popup: self.currentPopup)
                print(error)
                    
                switch(error) {
                case SolveError.UnknownError:
                    self.showError()
                    break
                case SolveError.InvalidQuestionError:
                    self.showError(message: "Can't answer that!")
                    break
                default:
                    self.showError()
                    break
                }
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(self.disposeBag)
    }
    
    func processImageForMultipleChoice(image: UIImage) {
        convertImageToText(image: image)
            //.subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS.background))
            .subscribe(onNext: { (text) in
                if text != nil && text != "" {
                    print(text!)
                    self.hidePopup(popup: self.currentPopup)
                    self.showEdit(text: text!)
                }
                else {
                    self.hidePopup(popup: self.currentPopup)
                    self.showError(message: "Couldn't read that. Make sure your picture is clear and has no handwriting!")
                }
            }, onError: { (error) in
                print(error)
                self.hidePopup(popup: self.currentPopup)
                self.showError()
            }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
    }
}
