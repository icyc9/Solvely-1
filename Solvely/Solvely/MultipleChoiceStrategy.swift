//
//  MultipleChoiceStrategy.swift
//  Solvely
//
//  Created by Daniel Christopher on 11/8/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import RxSwift

class Answer: StrategyResult {
    var question: String!
    var identifier: String!
    var text: String!
    var isMultipleChoiceAnswer: Bool!
}

enum SolveError: Error {
    case InvalidQuestionError(String)
    case UnknownError(String)
}

class MultipleChoiceStrategy: Strategy {
    
    func convertImageToText(image: UIImage?) -> Observable<String?> {
        return OCRService().convertImageToText(image: image)
    }
    
    func solve(input: String?) -> Observable<StrategyResult?> {
        let q = input!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = "http://solvelygateway-production.us-east-1.elasticbeanstalk.com/answer?question=\(q!)"
        
        let start = NSDate().timeIntervalSince1970
        return requestString(.get, url, headers: ["Content-Type": "application/json"])
            .flatMap { (response, data) -> Observable<StrategyResult?> in
                print(response)
                print(NSDate().timeIntervalSince1970 - start)
                if response.statusCode == 500 || response.statusCode == 400 {
                    return Observable.error(SolveError.InvalidQuestionError("Invalid question"))
                }
                else if response.statusCode != 200 {
                    return Observable.error(SolveError.UnknownError("Uknown error"))
                }
                
                do {
                    let data = try JSONSerialization.jsonObject(with: data.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    if let data = data as? [String: AnyObject] {
                        print(data)
                        for answer in data ["answers"] as! [[String: AnyObject]] {
                            if answer["correct_answer"] as! NSInteger == 1 {
                                let correctAnswer = Answer()
                                correctAnswer.identifier = answer["answer_choice"] as? String ?? ""
                                correctAnswer.text = answer["answer_text"] as? String ?? ""
                                correctAnswer.question = data["question"]!["text"] as? String ?? ""
                                let questionType = data["question"]!["type"] as? String ?? ""
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
