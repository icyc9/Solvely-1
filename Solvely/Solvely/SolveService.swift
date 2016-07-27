//
//  SolveService.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import RxAlamofire
import UIKit

protocol SolveServiceDelegate {
    func questionText(questionText: String)
    func questionAnswered(correctAnswer: String)
    func invalidQuestionFormat()
    func unknownError()
}

class SolveService: OCRServiceDelegate {
    private var ocrService = OCRService()
    var delegate: SolveServiceDelegate?
    
    func solve(question: String) {
        solveQuestion(question)
    }
    
    func convertImageToText(image: UIImage) {
        ocrService.delegate = self
        ocrService.convertImageToText(image)
    }
    
    func imageToTextError() {
        self.delegate!.unknownError()
    }
    
    func text(imageText: String) {
        self.delegate!.questionText(imageText)
    }
    
    private func solveQuestion(question: String) {
        delegate?.questionAnswered("A")
    }
}