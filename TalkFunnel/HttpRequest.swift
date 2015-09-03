//
//  HttpRequest.swift
//  Talk Funnel
//
//  Created by Jaison Titus on 31/07/15.
//  Copyright © 2015 Hasgeek. All rights reserved.
//

import Foundation

class HttpRequest {
    
    /*Takes the URL as a String and sets the request to only accept JSON and then calls HTTPsendRequest*/
    init(url: String,callback: (Dictionary<String, AnyObject>, String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")//to accept only JSON
        HTTPsendRequest(request) {
            (data: String, error: String?) -> Void in
            if error != nil {
                callback(Dictionary<String, AnyObject>(), error)
            } else {
                let jsonObj = self.JSONParse(data)
                callback(jsonObj, nil)
            }
        }
    }
    
    init(url: String,requestValue: String,requestHeader: String,callback: (Dictionary<String, AnyObject>, String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.setValue(requestValue, forHTTPHeaderField: requestHeader)
        //request.setValue("Bearer rmnkgHsGTOKPrZJdeKGAdw", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")//to accept only JSON
        HTTPsendRequest(request) {
            (data: String, error: String?) -> Void in
            if error != nil {
                callback(Dictionary<String, AnyObject>(), error)
            } else {
                let jsonObj = self.JSONParse(data)
                callback(jsonObj, nil)
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
    
    /* Converts the passed Data to a JSON Object */
    func JSONParse(jsonString: String) -> [String: AnyObject]{
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding){
            do{
                if let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]{
                    return jsonObj //returns a dictionary
                }
            }catch {
                return [String: AnyObject]()
            }
        }
        return [String: AnyObject]()
    }
    
    
    
}
