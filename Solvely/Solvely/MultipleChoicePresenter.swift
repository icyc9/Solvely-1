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
                self.showErrorPopUp(error: error)
            }).addDisposableTo(disposeBag)
    }
    
    func edit(text: String!) {
        showEditPopUp(text: text)
    }
    
    func solve(question: String!) {
        strategy.solve(input: question)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { answer in
                self.showAnswerPopUp(answer: answer)
            }, onError: { error in
                self.showErrorPopUp(error: error)
            }).addDisposableTo(disposeBag)
    }
    
    private func showLoadingPopUp() {
        let loadingPopUp = AnsweringPopUp.create()
        viewController.presentPopup(popup: loadingPopUp)
    }
    
    private func showErrorPopUp(error: Error?) {
        let errorPopUp = ErrorPopUp.create(message: "An error has occurred.", closeable: true, handler: nil)
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
