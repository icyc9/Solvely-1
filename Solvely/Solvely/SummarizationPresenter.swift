//
//  SummarizationPresenter.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class SummarizationPresenter: BasePresenter<SummarizeStrategy> {
    
    override init(viewController: HomeViewController, strategy: SummarizeStrategy, disposeBag: DisposeBag) {
        super.init(viewController: viewController, strategy: strategy, disposeBag: disposeBag)
    }
    
    override func edit(text: String!) {
        let editPopUp = EditQuestionPopUp.create(questionText: text, delegate: self)
        viewController.presentPopup(popup: editPopUp)
    }
    
    override func solveQuestionDidFinish(answer: StrategyResult?, error: Error?) {
        if error == nil {
            showSummarizedTextPopUp(answer: (answer as! SummarizeResult).summarization)
        }
        else {
            showSummarizeErrorPopUp(error: error)
        }
    }
    
    override func processImageDidFinish(text: String?, error: Error?) {
        if error == nil {
            edit(text: text)
        }
        else {
            showErrorPopUp(message: "Couldn't read that!")
        }
    }
    
    private func showSummarizedTextPopUp(answer: String?) {
        let summarizedPopUp = SummarizationPopUp.create(summarizedText: answer) { [weak self] cl in
            self?.viewController.hideCurrentPopup()
        }
        
        viewController.presentPopup(popup: summarizedPopUp)
    }
    
    private func showSummarizeErrorPopUp(error: Error!) {
        showErrorPopUp(message: "Couldn't summarize that!")
    }
}

extension SummarizationPresenter: SolvelyPopUpDelegate {
    
    func popUpDidClose() {
        viewController.hideCurrentPopup()
    }
}

extension SummarizationPresenter: EditQuestionPopUpDelegate {
    
    func didPressSolve(editedQuestion: String!) {
        solve(question: editedQuestion)
    }
}
