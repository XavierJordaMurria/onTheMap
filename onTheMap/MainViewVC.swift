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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var mainView: UIView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logInSucceed", name:"HTTPRequest_LogInSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logInFailed", name:"HTTPRequest_LogInFailedConnection", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logInFailedWrongCredentials", name:"HTTPRequest_LogInFailedCredentials", object: nil)
        mainView.userInteractionEnabled = true
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self) // Remove from all notifications being observed
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
        userName.text = "loebre@gmail.com"
        password.text = "sIRJORDAN21"

        if(!userName.hasText() || !password.hasText())
        {
            sendUserAlert("Alert",body: "need to set a user and password")
        }
        else
        {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            mainView.userInteractionEnabled = false
            HttpsRequestManager.sharedInstance.udacityLogIn(userName.text!, pass: password.text!)
        }
    }

    @IBAction func facebookLogIn(sender: AnyObject)
    {
//        if(!userName.hasText() || !password.hasText())
//        {
//            sendUserAlert("Alert",body: "need to set a user and password")
//        }
//        else
//        {
//            activityIndicator.hidden = false
//            activityIndicator.startAnimating()
//            mainView.userInteractionEnabled = false
//            HttpsRequestManager.sharedInstance.facebookLogIn("loebre@gmail.com", pass: "sIRJORDAN21")
////            HttpsRequestManager.sharedInstance.facebookLogIn(userName.text!, pass: password.text!)
//        }
        
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
    
    // MARK: - notifications
    /*!
    * @brief logInFailed notification got when couldn't stablish connection
    */
    func logInFailed()
    {
        mainView.userInteractionEnabled = true
        activityIndicator.stopAnimating()
        sendUserAlert("Alert",body: "Log In failed, failure to connect")
    }
    
    /*!
    * @brief logInFailedWrongCredentials got when the user||password are wrong 
    * and it is not possible to stablish a connection
    */
    func logInFailedWrongCredentials()
    {
        mainView.userInteractionEnabled = true
        activityIndicator.stopAnimating()
        sendUserAlert("Alert",body: "Account not found or invalid credentials.")
    }
    
    /*!
    * @brief logInSucceed notification got when the connection succed
    */
    func logInSucceed()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.mainView.userInteractionEnabled = true
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
            self.performSegueWithIdentifier("tabBarControllerSegue", sender: self)
        })
    }
}

