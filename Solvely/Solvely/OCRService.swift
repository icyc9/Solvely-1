//
//  OCRService.swift
//  Solvely
//
//  Created by Daniel Christopher on 8/27/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import RxSwift
import RxAlamofire

class OCRService {
    private let ocrEndpoint = "https://vision.googleapis.com/v1/images:annotate?"
    private let apiKey = "AIzaSyBTumwXnpvUbVZQCje8l1PYdojyd75g1lE"
    private let compressionPercent: CGFloat = 1
    
    func convertImageToText(image: UIImage?) -> Observable<String?> {
        if image == nil {
            return Observable.just("")
        }
        
        let compressed = compress(image!)
        
        return ocr(base64EncodeImage(compressed))
    }
    
    private func compress(image: UIImage) -> UIImage {
        let resized = image.resizeWithWidth(UIScreen.mainScreen().bounds.width)
        let data = resized!.mediumQualityJPEGNSData
        let compressed = UIImage(data: data)
        
        
        print(compressed?.size)
        print(data.length/1024)
        
        return compressed!
    }
    
    private func ocr(imageData: String) -> Observable<String?> {
        let url = ocrEndpoint.stringByAppendingString("key=\(apiKey)")
        
        let parameters: [String: AnyObject] = [
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
        
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "X-Ios-Bundle-Identifier": NSBundle.mainBundle().bundleIdentifier ?? ""
        ]
        
        return requestJSON(.POST, NSURL(string: url)!, parameters: parameters, encoding: .JSON, headers: headers)
            .map({ (response, data) -> String in
                
                if let json = data as? [String: AnyObject] {
                    if let responses = json["responses"] as? [[String: AnyObject]] {
                        if let annotations = responses[0]["textAnnotations"] as? [[String: AnyObject]] {
                            if annotations.count > 0 {
                                return annotations[0]["description"] as? String ?? ""
                            }
                        }
                    }
                }
                
                return ""
            })
    }
    
    private func base64EncodeImage(image: UIImage) -> String {
        let imagedata = UIImagePNGRepresentation(image)
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
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