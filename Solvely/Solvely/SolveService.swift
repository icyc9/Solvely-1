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
    func questionAnswered(correctAnswer: SolveResult)
    func unknownError()
    func unableToAnswer()
}

class Answer {
    var answerText: String?
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
    var question: String?
}

class SolveService {
    var delegate: SolveServiceDelegate?
    
    func solve(question: String) {
        let result = SolveResult()
        result.answerChoices = []
        result.question = ""
        
        //self.delegate?.questionAnswered(result)
        let q = question.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = "http://solvelygateway-dev-env.us-east-1.elasticbeanstalk.com/answer?question=\(q)"
        print(url)
        requestString(.GET, url, headers: ["Content-Type": "application/json"])
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (response, data) in
                
                if response.statusCode == 500 {
                    self.delegate?.unableToAnswer()
                    return
                }
                else if response.statusCode != 200 {
                    self.delegate?.unknownError()
                    return
                }
                
                do {
                    let data = try NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
                
                    if let data = data as? [String: AnyObject] {
                        print(data)
                        let result = SolveResult()
                        
                        var answers: [Answer] = []
                        
                        for ans in (data["answers"] as! [[String: AnyObject]]) {
                            var answer = Answer()
                            
                            //                        var backgroundInfo: [BackgroundInfo] = []
                            //
                            //                        for info in ans["background_info"] as! [[String: AnyObject]] {
                            //                            let b = BackgroundInfo()
                            //                            b.sentenceChunk = info["sentence_chunk"] as? String
                            //                            b.backgroundInfoAboutChunk = info["background_info_about_chunk"] as? String
                            //                            print(info)
                            //                            backgroundInfo.append(b)
                            //                        }
                            
                            //                      answer.backgroundInfo = backgroundInfo
                            answer.answerText = ans["answer_text"] as? String
                            answer.correctAnswer = ans["correct_answer"] as? Bool
                            answer.answerIdentifier = ans["answer_choice"] as? String
                            
                            answers.append(answer)
                        }
                        
                        result.answerChoices = answers
                        
                        let question = data["question"] as! [String: AnyObject]
                        
                        var q = Question()
                        
                        //                    let bginfo = question["background_info"] as! [[String: AnyObject]]
                        //                    var backgroundInfo: [BackgroundInfo] = []
                        //
                        //                    for info in bginfo {
                        //                        var b = BackgroundInfo()
                        //                        b.backgroundInfoAboutChunk = info["background_info_about_chunk"] as? String
                        //                        b.sentenceChunk = info["sentence_chunk"] as? String
                        //                        
                        //                        backgroundInfo.append(b)
                        //                    }
                        
                        //                    q.backgroundInfo = backgroundInfo
                        //                    
                        //                    result.question = q
                        
                        result.question = question["text"] as! String
                        
                        print(result)
                        self.delegate?.questionAnswered(result)
                    }
                }
                catch {
                    print(error)
                    self.delegate?.unableToAnswer()
                }
            })
    }
}