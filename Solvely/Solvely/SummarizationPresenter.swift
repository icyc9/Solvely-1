//
//  SummarizationPresenter.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class SummarizationPresenter: Presenter {
    weak var viewController: HomeViewController!
    var strategy: MultipleChoiceStrategy!
    var disposeBag: DisposeBag!
    
    init(viewController: HomeViewController, strategy: MultipleChoiceStrategy, disposeBag: DisposeBag) {
        self.viewController = viewController
        self.strategy = strategy
        self.disposeBag = disposeBag
    }
    
    func processImage(image: UIImage!) {
        
    }
    
    func edit(text: String!) {
        
    }
    
    func solve(question: String!) {
        
    }
}
