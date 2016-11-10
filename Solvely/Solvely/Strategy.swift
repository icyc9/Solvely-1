//
//  Strategy.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/8/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

protocol Strategy {
    associatedtype Result
    
    func convertImageToText(image: UIImage?) -> Observable<String?>
    func solve(input: String?) -> Observable<Result>
}
