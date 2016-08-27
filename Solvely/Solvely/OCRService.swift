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
import TesseractOCR

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
//        var tesseract:G8Tesseract = G8Tesseract(language:"eng");
//        //tesseract.language = "eng+ita";
//        //tesseract.delegate = self;
//        tesseract.charWhitelist = "01234567890";
//        tesseract.image = image
//        tesseract.recognize();
//        
//        NSLog("%@", tesseract.recognizedText);
//        
//        return
        
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
        client.PostRequest(&params, hodApp: "ocrdocument", requestMode: HODClient.REQ_MODE.SYNC)
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
        text = autocorrect(text)
        
        print(text)
        
        return text
    }
    
    private func autocorrect(var text: String) -> String {
        let checker = UITextChecker()
        
        for word in text.wordList {
            let misspelledRange = checker.rangeOfMisspelledWordInString(
                word, range: NSRange(0..<word.utf16.count),
                startingAt: 0, wrap: false, language: "en_US")
            
            // Auto correct word
            if misspelledRange.location != NSNotFound,
                let guesses = checker.guessesForWordRange(
                    misspelledRange, inString: word, language: "en_US") as? [String] {
                if guesses.first != nil {
                    text = text.stringByReplacingOccurrencesOfString(word, withString: "(\(guesses.first!))")
                }
            }
        }
        
        return text
    }
    
    private func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890),.!_?:%$\n".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    func base64EncodeImage(image: UIImage) -> String {
        let imagedata = UIImagePNGRepresentation(image)
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    func googleOCR(image: UIImage) {
        let resized = image.resizeWithPercentage(0.5)
        let data = resized!.mediumQualityJPEGNSData
        let compressed = UIImage(data: data)
        
        print(compressed?.size)
        print(data.length/1024)
        
        createRequest(base64EncodeImage(compressed!))
    }
    
    func createRequest(imageData: String) {
        // Create our request URL
        let request = NSMutableURLRequest(
            URL: NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=\("AIzaSyBYujLfKB2ZLsZI-cnCssdWkqkTpjOpJqk")")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(
            NSBundle.mainBundle().bundleIdentifier ?? "",
            forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest: [String: AnyObject] = [
            "requests": [
                "imageContext": [
                    "languageHints": [
                        "en"
                    ],
                ],
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 50
                    ]
                ]
            ]
        ]
        
        // Serialize the JSON
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonRequest, options: [])
        
        // Run the request on a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.runRequestOnBackgroundThread(request)
        });
        
    }
    
    func runRequestOnBackgroundThread(request: NSMutableURLRequest) {
        
        let session = NSURLSession.sharedSession()
        
        // run the request
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json = JSON(data: data!)
            print(json["textAnnotations"]["boundingPoly"])
            
        })
        task.resume()
    }
}

extension UIImage {
    
    func resizeWithPercentage(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}

extension String {
    var wordList: [String] {
        return componentsSeparatedByCharactersInSet(.punctuationCharacterSet())
            .joinWithSeparator("")
            .componentsSeparatedByString(" ")
    }
}