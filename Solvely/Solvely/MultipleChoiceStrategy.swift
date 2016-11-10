//
//  MultipleChoiceStrategy.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/8/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class MultipleChoiceStrategy: Strategy {
    
    func convertImageToText(image: UIImage?) -> Observable<String?> {
        return OCRService().convertImageToText(image: image)
    }
    
    func solve(input: String?) -> Observable<Answer?> {
        return SolveService().solveQuestion(question: input)
    }
    
}
