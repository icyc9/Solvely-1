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
import Gloss

protocol SolveServiceDelegate {
    func questionText(questionText: String)
    func questionAnswered(correctAnswer: SolveResult)
    func invalidQuestionFormat()
    func unknownError()
    func unableToAnswer()
}

class Answer {
    var answerText: String?
    var backgroundInfo: [BackgroundInfo]?
    var correctAnswer: Bool?
    var answerIdentifier: String?
}

class BackgroundInfo {
    var sentenceChunk: String?
    var backgroundInfoAboutChunk: String?
}

class Question {
    var questionText: String!
    var backgroundInfo: [BackgroundInfo]?
}

class SolveResult {
    var answerChoices: [Answer]?
    var question: Question?
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
                self.delegate?.unknownError()
            })
            .subscribe(onNext: { (response, data) in
                
                guard response.statusCode == 200 else {
                    self.delegate?.unknownError()
                    return
                }
                
                if let data = data as? [String: AnyObject] {
                    print(data)
                    let result = SolveResult()
                
                    var answers: [Answer] = []
                    
                    for ans in (data["answers"] as! [[String: AnyObject]]) {
                        var answer = Answer()
                        
                        var backgroundInfo: [BackgroundInfo] = []
                        
                        for info in ans["background_info"] as! [[String: AnyObject]] {
                            let b = BackgroundInfo()
                            b.sentenceChunk = info["sentence_chunk"] as? String
                            b.backgroundInfoAboutChunk = info["background_info_about_chunk"] as? String
                            print(info)
                            backgroundInfo.append(b)
                        }
                        
                        answer.backgroundInfo = backgroundInfo
                        answer.answerText = ans["answer_text"] as? String
                        answer.correctAnswer = ans["correct_answer"] as? Bool
                        answer.answerIdentifier = ans["answer_choice"] as? String
                        
                        answers.append(answer)
                    }
                    
                    result.answerChoices = answers
                    
                    let question = data["question"] as! [String: AnyObject]
                    
                    var q = Question()
                    q.questionText = question["text"] as! String
                    
                    let bginfo = question["background_info"] as! [[String: AnyObject]]
                    var backgroundInfo: [BackgroundInfo] = []
                    
                    for info in bginfo {
                        var b = BackgroundInfo()
                        b.backgroundInfoAboutChunk = info["background_info_about_chunk"] as? String
                        b.sentenceChunk = info["sentence_chunk"] as? String
                        
                        backgroundInfo.append(b)
                    }
                    
                    q.backgroundInfo = backgroundInfo
                    
                    result.question = q
                    
                    print(result)
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