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
    
    func solve(image: UIImage) {
        ocrService.delegate = self
        ocrService.convertImageToText(image)
    }
    
    func imageToTextError() {
        self.delegate!.unknownError()
    }
    
    func text(imageText: String) {
        self.delegate!.questionText(imageText)
        
        solveQuestion(imageText)
    }
    
    private func solveQuestion(question: String) {
        requestJSON(.GET, "http://192.168.1.11:5000/answer", parameters: ["question": question])
            .doOnError({ error in
                print(error)
                self.delegate!.unknownError()
            })
            .subscribe(onNext: { (response, data) in
                if response.statusCode == 200 {
                    print(response)
                
                    if let json = data as? [String: AnyObject] {
                        print(json)
                    
                        // todo: use actual json response
                        self.delegate!.questionAnswered("A")
                    }
                }
                else if response.statusCode == 400 {
                    self.delegate!.invalidQuestionFormat()
                }
                else {
                    self.delegate!.unknownError()
                }
            })
    }
}