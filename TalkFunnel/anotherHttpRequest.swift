//
//  anotherHttpRequest.swift
//  TalkFunnel
//
//  Created by Jaison Titus on 18/08/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

class anotherHttpRequest {
    
    /*Takes the URL as a String and sets the request to only accept JSON and then calls HTTPsendRequest*/
    init(url: String,callback: (AnyObject, String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.setValue("Bearer rmnkgHsGTOKPrZJdeKGAdw", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")//to accept only JSON
        HTTPsendRequest(request) {
            (data: String, error: String?) -> Void in
            if error != nil {
                callback(Dictionary<String, AnyObject>(), error)
            } else {
                callback(data, nil)
            }
        }
    }
    
    
    func HTTPsendRequest(request: NSMutableURLRequest,callback: (String, String?) -> Void) {
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request,completionHandler :
            {
                data, response, error in
                if error != nil {
                    callback("", (error!.localizedDescription) as String)
                } else {
                    callback(NSString(data: data!, encoding: NSUTF8StringEncoding) as! String,nil)
                }
        })
        task!.resume()//Tasks are called with a .resume()
    }
    

    
    
}