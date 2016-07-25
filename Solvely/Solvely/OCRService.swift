//
//  OCRService.swift
//  Solvely
//
//  Created by Daniel Christopher on 7/25/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import UIKit
import SwiftyJSON
import havenondemand

class OCRService: HODClientDelegate {
    
    func requestCompletedWithJobID(response: String) {
        print(response)
    }
    
    func requestCompletedWithContent(response: String) {
        print(response)
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
    
    func base64EncodeImage(image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        let oldSize: CGSize = image.size
        let newSize: CGSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        imagedata = resizeImage(newSize, image: image)
        
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    func havenOCR(imageData: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.havenondemand.com/1/api/sync/ocrdocument/v1?apikey=\("1c028361-2a40-4eb0-8d6e-d74d6061d83d")")!)
        request.HTTPMethod = "GET"
        
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
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 1
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
            print(json)
        })
        task.resume()
    }
    
}