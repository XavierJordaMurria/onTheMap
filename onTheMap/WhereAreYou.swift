//
//  WhereAreYou.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 23/01/2016.
//  Copyright © 2016 xjm. All rights reserved.
//

import UIKit
import MapKit

class WhereAreYou: UIViewController, UITextViewDelegate
{
        
    @IBOutlet weak var firstView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textViewAddress: UITextView!
    @IBOutlet weak var textViewURL: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //add textViewAddress delegate
        textViewAddress.delegate = self
        textViewURL.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        mainView.userInteractionEnabled = true
        secondView.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postStudentLocationSucceed", name:"HTTPRequest_postStudentLocationSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postStudentLocationFailed", name:"HTTPRequest_postStudentLocationFailed", object: nil)
        
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
    
    // MARK: - action methods
    @IBAction func cancelButton(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }

    @IBAction func findOnMapButton(sender: AnyObject)
    {
        if(textViewURL.text == nil)
        {
            let alert = UIAlertController(title: "Location field is requiered", message: "Please set a location", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            showhideActivityIndicator(false)
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(textViewAddress.text, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil)
                {
                    print("Error", error)
                    
                    let alert = UIAlertController(title: "Problem getting address", message: "Please set another address", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    self.showhideActivityIndicator(true)
                }
                else
                {
                    if let placemark = placemarks?.first
                    {
                        let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                        
                        // set initial location
                        let initialLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                        let regionRadius: CLLocationDistance = 1000
                        
                        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
                            regionRadius * 2.0, regionRadius * 2.0)
                        self.mapView.setRegion(coordinateRegion, animated: true)
                        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                        
                        DataModel.sharedInstance.udacityStudentStruct.mapString = self.textViewAddress.text
                        DataModel.sharedInstance.udacityStudentStruct.longitude = coordinates.longitude
                        DataModel.sharedInstance.udacityStudentStruct.latitude = coordinates.latitude
                    }
                 
                    self.showhideActivityIndicator(true)
                    
                    self.secondView.hidden = false
                    self.firstView.hidden = true
                }
            })
        }
    }
    
    @IBAction func submitAction(sender: AnyObject)
    {
        if(textViewURL.text == nil)
        {
            let alert = UIAlertController(title: "URL field is requiered", message: "Please set an URL", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if(!Reachability.isConnectedToNetwork())
        {
            let alert = UIAlertController(title: "No internet connection", message: "Please enable the wifi or connect to a wifi network to realize this action", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            showhideActivityIndicator(false)
            
            DataModel.sharedInstance.udacityStudentStruct.mediaURL = textViewURL.text
            HttpsRequestManager.sharedInstance.submitUserLoction()
        }
    }
    
    // MARK: - Keyboard methods
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Notification methods
    /*!
    * @brief postStudentLocationSucceed: called in the notification call back if the postStudentLocation request has been successfull.
    */
    func postStudentLocationSucceed()
    {
        showhideActivityIndicator(true)
        
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    /*!
    * @brief postStudentLocationFailed: called in the notification call back if the postStudentLocation request hasn't been successfull.
    */
    func postStudentLocationFailed()
    {
        showhideActivityIndicator(true)
        
        let alert = UIAlertController(title: "Post Studen Location failure", message: "There has been an unknow problem posting your location. Please try again", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        mainView.userInteractionEnabled = true
        secondView.hidden = true
    }
    
    // MARK: - UITEXTVIEWDELEGATE METHODS
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        textView.text = ""
    }
    
    /*!
    * @brief showhideActivityIndicator: called to start/stop show/hidde the activity intdicator
    */
    func showhideActivityIndicator(hidden: Bool)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            if(hidden)
            {
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
            }
            else
            {
                self.activityIndicator.hidden = false
                self.activityIndicator.startAnimating()
            }
        }
    }
}
