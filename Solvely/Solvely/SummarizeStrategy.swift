//
//  SummarizeStrategy.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class SummarizeStrategy: Strategy {
    
    func convertImageToText(image: UIImage?) -> Observable<String?> {
        return OCRService().convertImageToText(image: image)
    }
    
    func solve(input: String?) -> Observable<String?> {
        return Observable.just("This is a summarization!")
    }
}
