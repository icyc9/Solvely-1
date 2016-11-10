//
//  Presenter.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/9/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation

protocol Presenter {
    func processImage(image: UIImage!)
    func edit(text: String!)
    func solve(question: String!)
}
