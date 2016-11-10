//
//  MultipleChoicePresenter.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class MultipleChoicePresenter: Presenter {
    weak var viewController: HomeViewController!
    var strategy: MultipleChoiceStrategy!
    var disposeBag: DisposeBag!
    
    init(viewController: HomeViewController, strategy: MultipleChoiceStrategy, disposeBag: DisposeBag) {
        self.viewController = viewController
        self.strategy = strategy
        self.disposeBag = disposeBag
    }
    
    func processImage(image: UIImage!) {
        showLoadingPopUp()
        
        strategy.convertImageToText(image: image)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { text in
                print(text)
                self.edit(text: text)
            }, onError: { error in
                self.showSolveErrorPopUp(error: error as! SolveError)
            }).addDisposableTo(disposeBag)
    }
    
    func edit(text: String!) {
        showEditPopUp(text: text)
    }
    
    func solve(question: String!) {
        showLoadingPopUp()
        
        strategy.solve(input: question)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { answer in
                self.showAnswerPopUp(answer: answer)
            }, onError: { error in
                self.showSolveErrorPopUp(error: error)
            }).addDisposableTo(disposeBag)
    }
    
    private func showLoadingPopUp() {
        let loadingPopUp = AnsweringPopUp.create()
        viewController.presentPopup(popup: loadingPopUp)
    }
    
    private func showSolveErrorPopUp(error: Error) {
        switch error {
        case SolveError.UnknownError:
            showErrorPopUp()
            break
        case SolveError.InvalidQuestionError:
            showErrorPopUp(message: "Couldn't answer that!")
            break
        default:
            showErrorPopUp()
            break
        }
    }
    
    private func showErrorPopUp(message: String! = "An error has occurred.") {
        let errorPopUp = ErrorPopUp.create(message: message, closeable: true) { [weak self] cl in
            self?.viewController.hideCurrentPopup()
        }
        
        viewController.presentPopup(popup: errorPopUp)
    }
    
    private func showEditPopUp(text: String!) {
        let popup = EditQuestionPopUp.create(questionText: text, delegate: self)
        viewController.presentPopup(popup: popup)
    }
    
    private func showAnswerPopUp(answer: Answer!) {
        let popup = AnswerPopUp.create(answer: answer, delegate: self)
        viewController.presentPopup(popup: popup)
    }
}

extension MultipleChoicePresenter: SolvelyPopUpDelegate {

    func popUpDidClose() {
        viewController.popUpDidClose()
    }
}

extension MultipleChoicePresenter: EditQuestionPopUpDelegate {
    
    func didPressSolve(editedQuestion: String!) {
        solve(question: editedQuestion)
    }
}
