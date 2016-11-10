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
import Alamofire

class OCRService {
    private let ocrEndpoint = "https://vision.googleapis.com/v1/images:annotate?"
    private let apiKey = "AIzaSyCZxLLakWO_vmA_tj7cvZpe_9if3TVw90Y"
    private let compressionPercent: CGFloat = 1
    
    func convertImageToText(image: UIImage?) -> Observable<String?> {
        if image == nil {
            return Observable.just("")
        }
        
        print("converting")
        let compressed = compress(image: image!)
        
        return ocr(imageData: base64EncodeImage(image: compressed))
    }
    
    private func compress(image: UIImage) -> UIImage {
        let resized = image.resizeWithWidth(width: UIScreen.main.bounds.width)
        let data = resized!.mediumQualityJPEGNSData
        let compressed = UIImage(data: data as Data)
        
        
        print(compressed?.size)
        print(data.length/1024)
        
        return compressed!
    }
    
    private func ocr(imageData: String) -> Observable<String?> {
        let url = ocrEndpoint.appendingFormat("key=\(apiKey)")
        
        let parameters: [String: Any] = [
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
            "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""
        ]
        
        return requestJSON(.post, URL(string: url)!, parameters: parameters,encoding: JSONEncoding.default, headers: headers)
            .map({ (response, data) -> String in
                print(data)
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
        return imagedata!.base64EncodedString()
    }
}

extension UIImage {
    
    func resizeWithPercentage(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)! as NSData        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)! as NSData  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! as NSData }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)! as NSData  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! as NSData }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)! as NSData  }
}
