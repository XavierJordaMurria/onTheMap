//
//  HttpsRequestManager.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 16/12/2015.
//  Copyright © 2015 xjm. All rights reserved.
//

import Foundation

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
        
        let task = session.dataTaskWithRequest(request)  { data, response, error in
           
            // Handle error…
            if error != nil
            {
                NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInFailed", object: nil)
                return
            }
                
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
            self.parseUdacityLogInData(newData)
            NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInSucced", object: nil)
        }
        task.resume()
    }
    
    func facebookLogIn(user:String, pass:String)
    {
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
//        let fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        let accessToken = FBSDKAccessToken.currentAccessToken()
        
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = accessToken.tokenString.dataUsingEncoding(NSUTF8StringEncoding)
       
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil
            {
                 NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInFailed", object: nil)
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInSucced", object: nil)
        }
        
        task.resume()
    }
    
    func parseUdacityLogInData(dataFromNetworking: NSData)
    {
        //expected data
       // Optional({"account": {"registered": true, "key": "2987668569"}, "session": {"id": "1481973610S0b90d77a3c1df94ff1becba7903c7192", "expiration": "2016-02-16T11:20:10.019830Z"}})
        
        print("\(TAG)parseUdacityLogInDate")
        
        do
        {
            if let json = try NSJSONSerialization.JSONObjectWithData(dataFromNetworking, options: []) as? NSDictionary
            {
                print(json)
                
                if let account_registered = json["account"]!["registered"] as! Bool?
                {
                    onTheMapDelegate.udacityLogInStruct.accountRegistered = account_registered
                    print("\(TAG)account_registered: \(account_registered)")
                }
                
                if let account_key = json["account"]!["key"] as! String?
                {
                    onTheMapDelegate.udacityLogInStruct.accountKey = account_key
                    print("\(TAG)account_key : \(account_key)")
                }
                
                if let session_id = json["session"]!["id"] as! String?
                {
                    onTheMapDelegate.udacityLogInStruct.sessionID = session_id
                    print("\(TAG)session_id: \(session_id)")
                }
                
                if let session_expiration = json["session"]!["expiration"] as! String?
                {
                    onTheMapDelegate.udacityLogInStruct.sessionExpiration = session_expiration
                    print("\(TAG)session_expiration: \(session_expiration)")
                } 
            }
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
        }
    }
    
    func gettingStudentsLocation()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(request)
            { data, response, error in
                
                // Handle error...
                if error != nil
                {
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationFailed", object: nil)
                    return
                }
                else
                {
                    self.parseStudentsLocationsData(data!)
                }
            }
        task.resume()
    }
    
    func parseStudentsLocationsData(data: NSData)
    {
        do
        {
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
            {
                onTheMapDelegate.studentsLocationDic = jsonResult
                NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationSucced", object: nil)
                
                print(onTheMapDelegate.studentsLocationDic)
            }
        }
        catch let error as NSError
        {
            NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationFailed", object: nil)
            print(error.localizedDescription)
        }
    }
}