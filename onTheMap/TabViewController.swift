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
    var studentsDataLoc: NSArray?
    let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refresh: UIBarButtonItem!
    
    // MARK: -
    
    override func viewDidLoad()
    {
        // The "locations" array is an array of dictionary objects that are equal to the JSON
        // data that you can download from parse.
        studentsDataLoc = onTheMapDelegate.studentsLocationArray
        
        //LogIn Notifications listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationSucceed", name:"HTTPRequest_StudentsLocationSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationFailed", name:"HTTPRequest_StudentsLocationFailed", object: nil)
        
        //Log Out Notifications Listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutSucceed", name:"HTTPRequest_LogOutSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutSucceed", name:"HTTPRequest_LogOutFailed", object: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return studentsDataLoc!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let studentLocation = studentsDataLoc![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? StudentTableCells!
        let name:String =  studentLocation["firstName"] as! String
        let lastName:String = studentLocation["lastName"] as! String
            
        cell!.studentCellName.text = "\(name) \(lastName)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        currentIntdex = indexPath.row
        performSegueWithIdentifier("tab2DetailsView", sender: self)
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
//        if segue.identifier == "tab2DetailsView"
//        {
//            // Create a new variable to store the instance of PlayerTableViewController
//            let destinationVC = segue.destinationViewController as! DetailViewController
//            
//            if let index = currentIntdex
//            {
//                print("About to segue to DetailsView with index => \(index)")
//                destinationVC.currentIndex = index
//            }
//        }
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.uiBusy.stopAnimating()
            self.studentsDataLoc = self.onTheMapDelegate.studentsLocationArray
            
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButton:")
            self.navigationItem.rightBarButtonItem = refreshButton
        })
    }
    
    func studentsLocationFailed()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: "Failed loading data", message: "loading students location has failed for unknown reasons", preferredStyle: UIAlertControllerStyle.Alert)
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: "Failed to LogOut", message: "LoggingOut has failed for unknown reasons", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}

