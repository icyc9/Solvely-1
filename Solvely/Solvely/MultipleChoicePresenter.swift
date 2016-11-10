//
//  MultipleChoicePresenter.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class MultipleChoicePresenter: BasePresenter<MultipleChoiceStrategy> {
    
    override init(viewController: HomeViewController, strategy: MultipleChoiceStrategy, disposeBag: DisposeBag) {
        super.init(viewController: viewController, strategy: strategy, disposeBag: disposeBag)
    }
    
    override func processImage(image: UIImage!) {
        super.processImage(image: image)
        showLoadingPopUp()
    }
    
    override func edit(text: String!) {
        super.edit(text: text)
        showEditPopUp(text: text)
    }
    
    override func solve(question: String!) {
        super.solve(question: question)
        showLoadingPopUp()
    }
    
    private func showLoadingPopUp() {
        let loadingPopUp = AnsweringPopUp.create()
        viewController.presentPopup(popup: loadingPopUp)
    }
    
    override func processImageDidFinish(text: String?, error: Error?) {
        if error == nil {
            showEditPopUp(text: text)
        }
        else {
            showErrorPopUp(message: "Couldn't read that!")
        }
    }
    
    override func solveQuestionDidFinish(answer: Answer?, error: Error?) {
        if error == nil {
            showAnswerPopUp(answer: answer!)
        }
        else {
            showSolveErrorPopUp(error: error!)
        }
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
