//
//  SolveService.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import RxSwift
import RxAlamofire

class Answer {
    var question: String!
    var identifier: String!
    var text: String!
    var isMultipleChoiceAnswer: Bool!
}

enum SolveError: ErrorType {
    case InvalidQuestionError(String)
    case UnknownError(String)
}

class SolveService {
    
    func solveQuestion(question: String?) -> Observable<Answer?> {
        let q = question!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = "http://solvelygateway-production.us-east-1.elasticbeanstalk.com/answer?question=\(q)"
        
        let start = NSDate().timeIntervalSince1970
        return requestString(.GET, url, headers: ["Content-Type": "application/json"])
            .flatMap { (response, data) -> Observable<Answer?> in
                print(NSDate().timeIntervalSince1970 - start)
                if response.statusCode == 500 {
                    return Observable.error(SolveError.InvalidQuestionError("Invalid question"))
                }
                else if response.statusCode != 200 {
                    return Observable.error(SolveError.UnknownError("Uknown error"))
                }
                
                do {
                    let data = try NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
                    
                    if let data = data as? [String: AnyObject] {
                        print(data)
                        for answer in data ["answers"] as! [[String: AnyObject]] {
                            if answer["correct_answer"] as! NSInteger == 1 {
                                let correctAnswer = Answer()
                                correctAnswer.identifier = answer["answer_choice"] as? String ?? ""
                                correctAnswer.text = answer["answer_text"] as? String ?? ""
                                correctAnswer.question = data["question"]!["text"] as! String ?? ""
                                let questionType = data["question"]!["type"] as! String ?? ""
                                correctAnswer.isMultipleChoiceAnswer = questionType == "multiple_choice"
                                
                                return Observable.just(correctAnswer)
                            }
                        }
                    }
                }
                catch {
                    print(error)
                    return Observable.error(SolveError.UnknownError("Unknown error"))
                }
                
                return Observable.just(nil)
        }
    }
}