//
//  SummarizeStrategy.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class SummarizeResult: StrategyResult {
    var summarization: String?
}

class SummarizeStrategy: Strategy {
    
    func convertImageToText(image: UIImage?) -> Observable<String?> {
        return OCRService().convertImageToText(image: image)
    }
    
    func solve(input: String?) -> Observable<StrategyResult?> {
        let summarizeResult = SummarizeResult()
        summarizeResult.summarization = "What I mean is, suppose a ball is fired from a cannon, it is clearly visible that the ball immediately starts moving with a high velocity. Suppose the ball is moving at 100 m/s in the first second. Would the ball have started from 1m/s to 2m/s and gradually arrived at 100m/s? And is the change so fast that we are not able to conceive it? Or does the ball actually start its motion at 100m/s as soon as the cannon is fired?"
        return Observable.just(summarizeResult)
    }
}
