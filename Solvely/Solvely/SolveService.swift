//
//  SolveService.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import RxAlamofire
import UIKit
import RxSwift

protocol SolveServiceDelegate {
    func questionText(questionText: String)
    func questionAnswered(correctAnswer: SolveResult)
    func invalidQuestionFormat()
    func unknownError()
}

class SolveResult {
    var answer: String!
    var answerChoices: [String]!
    var question: String!
}

class SolveService: OCRServiceDelegate {
    private var ocrService = OCRService()
    var delegate: SolveServiceDelegate?
    
    func solve(question: String) {
        let r = SolveResult()
        r.answer = "A) John Wilkes Booth"
        r.answerChoices = ["A) John Wilkes Booth", "B) Rob", "C) Karma"]
        r.question = "yo"
        delegate?.questionAnswered(r)
    }
    
    func convertImageToText(image: UIImage) {
        ocrService.delegate = self
        ocrService.convertImageToText(image)
    }
    
    func imageToTextError() {
        self.delegate!.unknownError()
    }
    
    func text(imageText: String) {
        if imageText.isEmpty {
            self.delegate!.invalidQuestionFormat()
        }
        else {
            self.delegate!.questionText(imageText)
        }
    }
    
    private func solveQuestion(question: String) -> Observable<SolveResult?> {
        return requestJSON(.GET, "", headers: ["Content-Type": "application/json"], encoding: .JSON)
            .observeOn(MainScheduler.instance)
            .map({ (response, data) -> SolveResult? in
                guard response.statusCode == 200 else {
                    return nil
                }
                
                if let json = data as? [String: AnyObject] {
                    let result = SolveResult()
                    result.answer = json["answer_letter"] as! String
                    result.answerChoices = json["answer_choices"] as! [String]
                    return result
                }
                
                return nil
            })
    }
}