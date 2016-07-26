//
//  SolveService.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import RxAlamofire
import UIKit

class SolveService: OCRServiceDelegate {
    private var ocrService = OCRService()
    
    func solve(image: UIImage) {
        ocrService.delegate = self
        ocrService.convertImageToText(image)
    }
    
    func text(imageText: String) {
        solveQuestion(imageText)
    }
    
    private func solveQuestion(question: String) {
        requestJSON(.GET, "http://192.168.1.11:5000/answer", parameters: ["question": question])
            .subscribe(onNext: { (response, data) in
                print(response)
                
                if let json = data as? [String: AnyObject] {
                    print(json)
                }
            })
    }
}