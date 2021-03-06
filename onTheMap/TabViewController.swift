//
//  TabViewController.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 09/01/2016.
//  Copyright © 2016 xjm. All rights reserved.
//
import UIKit

class TabViewController: UIViewController, UINavigationControllerDelegate
{
    var onTheMapDelegate: OnTheMapAppDelegate = (UIApplication.sharedApplication().delegate as! OnTheMapAppDelegate)
    var currentIntdex: Int? = nil
    let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refresh: UIBarButtonItem!
    
    // MARK: -
    override func viewDidLoad()
    {
        // The "locations" array is an array of dictionary objects that are equal to the JSON
        // data that you can download from parse.
        
        //LogIn Notifications listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationSucceed", name:"HTTPRequest_StudentsLocationSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationFailed", name:"HTTPRequest_StudentsLocationFailed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationUnauthorized", name:"HTTPRequest_StudentsLocationUnauthorized", object: nil)
        
        //Log Out Notifications Listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutSucceed", name:"HTTPRequest_LogOutSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutSucceed", name:"HTTPRequest_LogOutFailed", object: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        DataModel.sharedInstance.studentsLocationArray.sortInPlace({$0.updatedAt < $1.updatedAt})
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return DataModel.sharedInstance.studentsLocationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let studentLocation = DataModel.sharedInstance.studentsLocationArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? StudentTableCells!
        let name:String =  studentLocation.firstName!
        let lastName:String = studentLocation.lastName!
            
        cell!.studentCellName.text = "\(name) \(lastName)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let studentLocation = DataModel.sharedInstance.studentsLocationArray[indexPath.row]
        
        let app = UIApplication.sharedApplication()
        
        if let toOpen = studentLocation.mediaURL 
        {
            if(DataModel.sharedInstance.verifyUrl(toOpen))
            {
                app.openURL(NSURL(string: toOpen)!)
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                { () -> Void in
                    let alert = UIAlertController(title: "Invalid URL", message: "The URL has a wrong format", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
            { () -> Void in
                let alert = UIAlertController(title: "No URL", message: "The URL is empty", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - IBAcctions
    
    @IBAction func refreshButton(sender: AnyObject)
    {
        HttpsRequestManager.sharedInstance.gettingStudentsLocation()
        uiBusy.hidesWhenStopped = true
        uiBusy.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uiBusy)
        
    }
    
    @IBAction func setLocationButton(sender: AnyObject)
    {
    }
    
    @IBAction func logOutButton(sender: AnyObject)
    {
        HttpsRequestManager.sharedInstance.udacityLogOut()
    }
    
    // MARK: -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool
    {
        if(self.respondsToSelector(action))
        {
            return true
        }
        
        return false
    }

    // MARK: - Notifications callBack methods
    func studentsLocationSucceed()
    {
        dispatch_async(dispatch_get_main_queue(),
        { () -> Void in
            self.uiBusy.stopAnimating()
            
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButton:")
            self.navigationItem.rightBarButtonItem = refreshButton
        })
    }
    
    func studentsLocationFailed()
    {
        dispatch_async(dispatch_get_main_queue(),
        { () -> Void in
            let alert = UIAlertController(title: "Failed loading data", message: "loading students location has failed for unknown reasons", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func studentsLocationUnauthorized()
    {
        dispatch_async(dispatch_get_main_queue(),
            { () -> Void in
                let alert = UIAlertController(title: "Failed loading data", message: "loading students location has failed Unauthorized", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func logOutSucceed()
    {
        dispatch_async(dispatch_get_main_queue(),
        { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func logOutFailed()
    {
        dispatch_async(dispatch_get_main_queue(),
        { () -> Void in
            let alert = UIAlertController(title: "Failed to LogOut", message: "LoggingOut has failed for unknown reasons", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}

