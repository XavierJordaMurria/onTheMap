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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refresh: UIBarButtonItem!
    
    // MARK: - IBAcctions

    @IBAction func refreshButton(sender: AnyObject)
    {
        
    }
    
    @IBAction func setLocationButton(sender: AnyObject)
    {
    }
    
    @IBAction func logOutButton(sender: AnyObject)
    {
        
    }
    // MARK: -
    
    override func viewDidLoad()
    {
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        studentsDataLoc = onTheMapDelegate.studentsLocationDic["results"] as? NSArray
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
//        cell!.studentCellImage.image = meme.memeImage
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
}

