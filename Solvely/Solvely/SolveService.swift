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
        let q = question.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        print(q)
        requestJSON(.GET, "http://192.168.1.248:8080/answer?question=\(q)", headers: ["Content-Type": "application/json"], encoding: .JSON)
            .observeOn(MainScheduler.instance)
            .doOnError({ (error) in
                print(error)
            })
            .subscribe(onNext: { (response, data) in
                print(response)
                print(data)
                
                guard response.statusCode == 200 else {
                    self.delegate?.unknownError()
                    return
                }
                
                if let json = data as? [String: AnyObject] {
                    let result = SolveResult()
                    let prediction = (json["predictions"] as! [[String: AnyObject]])[0]
                    var parsed = "\(prediction["answer_choice"] as! String)) \(prediction["answer_text"] as! String)"
                    
                    if parsed.isEmpty {
                        parsed = "I am not yet smart enough to answer that."
                    }
                    
                    result.question = json["question"] as! String
                    result.answer = parsed
                    
                    var answers: [String] = []
                    for ans in json["answer_choices"] as! [[String: AnyObject]] {
                        answers.append("\(ans["answer_choice"] as! String)) \(ans["answer_text"] as! String)")
                    }
                    
                    result.answerChoices = answers
                    self.delegate?.questionAnswered(result)
                }
            })
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
}