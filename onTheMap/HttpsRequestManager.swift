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
    
    /*!
    * @brief udacityLogIn
    */
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInFailedConnection", object: nil)
                })
                return
            }
            else
            {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
                self.parseUdacityLogInData(newData)
            }
        }
        task.resume()
    }
    
    /*!
    * @brief udacityLogOut
    */
    func udacityLogOut()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies!
        {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil
            { // Handle error…
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogOutFailed", object: nil)
                })
                return
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogOutSucceed", object: nil)
                })
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))

        }
        
        task.resume()
    }
    
    /*!
    * @brief facebookLogIn
    */
    func facebookLogIn(user:String, pass:String)
    {
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        
        let accessToken = FBSDKAccessToken.currentAccessToken()
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = accessToken.tokenString.dataUsingEncoding(NSUTF8StringEncoding)
       
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil
            {
                dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                     NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInFailed", object: nil)
                })
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            dispatch_async(dispatch_get_main_queue(),
            { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInSucceed", object: nil)
            })
        }
        
        task.resume()
    }

    /*!
    * @brief gettingStudentsLocation
    */
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
                    dispatch_async(dispatch_get_main_queue(),
                    { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationFailed", object: nil)
                    })
                    return
                }
                else
                {
                    self.parseStudentsLocationsData(data!)
                }
            }
        task.resume()
    }
    
    /*!
    * @brief postingStudentsLocation
    */
    func postingStudentsLocation()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let defaultURLBody: String = "{\"uniqueKey\": \"field1\", \"firstName\": \"field2\", \"lastName\": \"field3\",\"mapString\": \"field4\", \"mediaURL\": \"field5\",\"latitude\": field6, \"longitude\":field7}"
        let tmpURLBodyfield1 = defaultURLBody.stringByReplacingOccurrencesOfString("field1", withString: DataModel.sharedInstance.udacityStudentStruct.accountKey!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let tmpURLBodyfield2 = tmpURLBodyfield1.stringByReplacingOccurrencesOfString("field2", withString: DataModel.sharedInstance.udacityStudentStruct.firstName!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let tmpURLBodyfield3 = tmpURLBodyfield2.stringByReplacingOccurrencesOfString("field3", withString: DataModel.sharedInstance.udacityStudentStruct.lastName!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let tmpURLBodyfield4 = tmpURLBodyfield3.stringByReplacingOccurrencesOfString("field4", withString: DataModel.sharedInstance.udacityStudentStruct.mapString!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
         let tmpURLBodyfield5 = tmpURLBodyfield4.stringByReplacingOccurrencesOfString("field5", withString: DataModel.sharedInstance.udacityStudentStruct.mediaURL!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let tmpURLBodyfield6 = tmpURLBodyfield5.stringByReplacingOccurrencesOfString("field6", withString: String(DataModel.sharedInstance.udacityStudentStruct.latitude!), options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let tmpURLBodyfield7 = tmpURLBodyfield6.stringByReplacingOccurrencesOfString("field7", withString: String(DataModel.sharedInstance.udacityStudentStruct.longitude!), options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        request.HTTPBody = tmpURLBodyfield7.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request)
            {
                data, response, error in
            if error != nil
            { // Handle error…
                dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_postStudentLocationSucceed", object: nil)
                })

                return
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_postStudentLocationSucceed", object: nil)
                    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                })
            }
        }
        task.resume()
    }
    
    /*!
    * @brief submitUserLoction
    */
    func submitUserLoction()
    {
        gettingPublicUserData()
    }
    
    /*!
    * @brief gettingPublicUserData
    */
    func gettingPublicUserData()
    {
        let defaultURLBody: String =  "https://www.udacity.com/api/users/userID"
        
        let tmpURLBodyUserID = defaultURLBody.stringByReplacingOccurrencesOfString("userID", withString: DataModel.sharedInstance.udacityStudentStruct.accountKey!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
         let request = NSMutableURLRequest(URL: NSURL(string: tmpURLBodyUserID)!)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request)
            {data, response, error in
             
                if error != nil
                { // Handle error...
                    return
                }
                else
                {
                    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                    self.parseStudenPublicData(newData)

                    // once we got all the needed information post the student location
                    self.postingStudentsLocation()
                }
        }
        task.resume()
    }
    
    // MARK: - PARSERS methods
    /*!
    * @brief parseStudentsLocationsData. it receives a json object containg 100 internal objects(dictionaries)
    * representing the students information.
    */
    func parseStudentsLocationsData(data: NSData)
    {
        do
        {
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
            {
                guard let tmpArr = jsonResult["results"] as? NSArray
                else
                {
                    guard let tmpErr = jsonResult["error"] as? NSString
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(),
                        { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationFailed", object: nil)
                        })
                        return
                    }
                    
                    if(tmpErr == "unauthorized")
                    {
                        dispatch_async(dispatch_get_main_queue(),
                        { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationUnauthorized", object: nil)
                        })
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(),
                        { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationFailed", object: nil)
                        })
                    }
                    return
                }
                
                print(tmpArr)

                for model in tmpArr
                {
                    guard   let modelDic = model as? NSDictionary
                        else    { break }
                    
                    let studentModel =  StudentModel(studentsLoctionProperties: modelDic)
                    DataModel.sharedInstance.studentsLocationArray.append(studentModel)
                }
                    
                dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_StudentsLocationSucceed", object: nil)
                })
            }
        }
        catch let parseError as NSError
        {
            print(parseError.localizedDescription)
            return
        }
    }
    
    /*!
    * @brief parseStudenPublicData
    */
    func parseStudenPublicData(dataFromNetworking: NSData)
    {
        do
        {
            if let json = try (NSJSONSerialization.JSONObjectWithData(dataFromNetworking, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary)
            {
                guard   let userDict = json["user"] as? [String: AnyObject],
                        let lastName = userDict["last_name"] as? String,
                        let firstName = userDict["first_name"] as? String
                else
                    { /* report no user information */
                        return
                    }
                
                print("Hello : \(firstName) \(lastName)")
                DataModel.sharedInstance.udacityStudentStruct.lastName = lastName
                DataModel.sharedInstance.udacityStudentStruct.firstName = firstName
            }
        }
        catch let parseError as NSError
        {
            print(parseError.localizedDescription)
            return
        }
    }
    
    /*!
    * @brief parseUdacityLogInData
    */
    func parseUdacityLogInData(dataFromNetworking: NSData)
    {
        //expected data
        // Optional({"account": {"registered": true, "key": "2987668569"}, "session": {"id": "1481973610S0b90d77a3c1df94ff1becba7903c7192", "expiration": "2016-02-16T11:20:10.019830Z"}})
        
        print("\(TAG)parseUdacityLogInDate")
        
        do
        {
            if let json = try (NSJSONSerialization.JSONObjectWithData(dataFromNetworking, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary)
            {
                print(json)
                
                guard   let account = json["account"] as? [String: AnyObject],
                        let account_registered = account["registered"] as? Bool,
                        let account_key = account["key"] as? String,
                        let session = json["session"] as? [String: AnyObject],
                        let session_id = session["id"] as? String,
                        let session_expiration = session["expiration"] as? String
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                    { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInFailedCredentials", object: nil)
                    })
                    
                    return
                }
                
                DataModel.sharedInstance.udacityStudentStruct.accountRegistered = account_registered
                DataModel.sharedInstance.udacityStudentStruct.accountKey = account_key
                DataModel.sharedInstance.udacityStudentStruct.sessionID = session_id
                DataModel.sharedInstance.udacityStudentStruct.sessionExpiration = session_expiration
                
                dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("HTTPRequest_LogInSucceed", object: nil)
                })
            }
        }
        catch let parseError as NSError
        {
            print(parseError.localizedDescription)
            return
        }
    }
}