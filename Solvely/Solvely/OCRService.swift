//
//  OCRService.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import havenondemand

protocol OCRServiceDelegate {
    func text(imageText: String)
    func imageToTextError()
}

class OCRService: HODClientDelegate {
    var delegate: OCRServiceDelegate?
    
    func requestCompletedWithJobID(response: String) {
    }
    
    func requestCompletedWithContent(var response: String) {
        let parser = HODResponseParser()
        
        if let res = parser.ParseOCRDocumentResponse(&response) {
            var result = ""
            for item in res.text_block {
                let i  = item as! OCRDocumentResponse.TextBlock
                result += "" + i.text + "\n"
            }
            
            if delegate != nil {
                delegate?.text(result)
            }
        }
    }
    
    func onErrorOccurred(errorMessage: String) {
        print(errorMessage)
    }
    
    func convertImageToText(image: UIImage) {
        let size = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        
        let resized = UIImagePNGRepresentation(image)
        
        // Create path.
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let filePath = "\(paths[0])/temp.png"
        
        // Save image.
        resized!.writeToFile(filePath, atomically: true)
        
        
        let client = HODClient(apiKey: "1c028361-2a40-4eb0-8d6e-d74d6061d83d", version: "v1")
    
        client.delegate = self
        
        var params =  Dictionary<String,AnyObject>()
        params["file"] = filePath
        params["mode"] = "document_photo"
//        client.PostRequest(&params, hodApp: "ocrdocument", requestMode: HODClient.REQ_MODE.SYNC)
        // TEMPORARILY RETURNING HARDCODED DATA BECAUSE I AM TESTING ON A HOTSPOT
        var text = "1) Who killed Abraham Lincoln?\nA) John Wilkes Booth\nB) George Washington\nC)John Adams"
        
        // Correct OCR output
        text = try! clean(text)
   
        delegate!.text(text)
    }
    
    func resizeImage(imageSize: CGSize, image: UIImage) -> NSData {
        UIGraphicsBeginImageContext(imageSize)
        image.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    private func clean(var text: String) throws -> String {
        // Remove leading and trailing whitespaces
        text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // Remove leading question number. Example: The "1)" in "1) question text"
        let regex = try NSRegularExpression(pattern: "\\d*\\)", options: [])
        let b = regex.matchesInString(text, options: [], range: NSRange(location: 0, length:  text.characters.count))
        
        // Matches found for question number
        if b.count > 0 {
            let match = b[0]
            // If the substring looking like a question number is at the beginning of the string, remove it. If not, it's probably not a question number so it can stay
            if match.range.location == 0 {
                let number = (text as NSString!).substringWithRange(match.range)
                text = text.stringByReplacingOccurrencesOfString(number, withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
        }
        
        text = removeSpecialCharsFromString(text)
        
        print(text)
        
        return text
    }
    
    private func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890),.!_?:%$\n".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
}