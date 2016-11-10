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
    
    override func processImage(image: UIImage!) {
        super.processImage(image: image)
    }
    
    override func edit(text: String!) {
        
    }
    
    override func solve(question: String!) {
        strategy.solve(input: question)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] answer in
                self?.showSummarizedTextPopUp(answer: answer)
            }, onError: { [weak self] error in
                self?.showSummarizeErrorPopUp(error: error)
            }).addDisposableTo(disposeBag)
    }
    
    private func showSummarizedTextPopUp(answer: String?) {
        
    }
    
    private func showSummarizeErrorPopUp(error: Error!) {
        
    }
}
