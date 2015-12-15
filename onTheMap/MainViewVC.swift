//
//  ViewController.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 13/12/2015.
//  Copyright © 2015 xjm. All rights reserved.
//

import UIKit

class MainViewVC: UIViewController
{

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Buttons methods
    
    @IBAction func singUpLink(sender: AnyObject)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin")!)
    }
    
    @IBAction func udacityLogIn(sender: AnyObject)
    {
        if(!userName.hasText() || !password.hasText())
        {
            sendUserAlert("Alert",body: "need to set a user and password")
        }
        else
        {            
            
            let defaultURLBody: String = "{\"udacity\": {\"username\": \"field1\", \"password\": \"field2\"}}"
            let tmpURLBody = defaultURLBody.stringByReplacingOccurrencesOfString("field1", withString: userName.text!, options: NSStringCompareOptions.LiteralSearch, range: nil)
            let newURLBody = tmpURLBody.stringByReplacingOccurrencesOfString("field2", withString: password.text!, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = newURLBody.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
            task.resume()
        }
        
    }

    @IBAction func facebookLogIn(sender: AnyObject)
    {
        
    }
    
    // MARK: - Keyboard methods
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func sendUserAlert(title: String, body: String)
    {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

