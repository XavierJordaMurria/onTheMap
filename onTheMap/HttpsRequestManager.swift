//
//  HttpsRequestManager.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 16/12/2015.
//  Copyright © 2015 xjm. All rights reserved.
//

import Foundation
import SwiftyJSON

class HttpsRequestManager
{
    
    static let sharedInstance = HttpsRequestManager()
    
    let TAG: String = "HttpsRequestManager: "
    var onTheMapDelegate: OnTheMapAppDelegate = (UIApplication.sharedApplication().delegate as! OnTheMapAppDelegate)
    
    func udacityLogIn(user: String, pass:String)
    {
        let defaultURLBody: String = "{\"udacity\": {\"username\": \"field1\", \"password\": \"field2\"}}"
        let tmpURLBody = defaultURLBody.stringByReplacingOccurrencesOfString("field1", withString: user, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let newURLBody = tmpURLBody.stringByReplacingOccurrencesOfString("field2", withString: pass, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
       
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = newURLBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request)
            {
                data, response, error in
           
            // Handle error…
            if error != nil
            {
                NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInFailed", object: nil)
                return
            }
                
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
            self.parseUdacityLogInData(newData)
//            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInSucced", object: nil)
        }
        task.resume()
    }
    
    func parseUdacityLogInData(dataFromNetworking: NSData)
    {
        //expected data
       // Optional({"account": {"registered": true, "key": "2987668569"}, "session": {"id": "1481973610S0b90d77a3c1df94ff1becba7903c7192", "expiration": "2016-02-16T11:20:10.019830Z"}})
        
        print("\(TAG)parseUdacityLogInDate")
        
        let json = JSON(data: dataFromNetworking)
        
        if let account_registered = json["account"]["registered"].bool
        {
            onTheMapDelegate.udacityLogInStruct.accountRegistered = account_registered
            print("\(TAG)account_registered: \(account_registered)")
        }
        
        if let account_key = json["account"]["key"].string
        {
            onTheMapDelegate.udacityLogInStruct.accountKey = account_key
            print("\(TAG)account_key : \(account_key)")
        }
        
        if let session_id = json["session"]["id"].string
        {
            onTheMapDelegate.udacityLogInStruct.sessionID = session_id
            print("\(TAG)session_id: \(session_id)")
        }
        
        if let session_expiration = json["session"]["expiration"].string
        {
            onTheMapDelegate.udacityLogInStruct.sessionExpiration = session_expiration
            print("\(TAG)session_expiration: \(session_expiration)")
        }
    }
}