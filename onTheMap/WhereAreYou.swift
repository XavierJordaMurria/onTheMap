    //
//  WhereAreYou.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 23/01/2016.
//  Copyright © 2016 xjm. All rights reserved.
//

import UIKit
import MapKit

class WhereAreYou: UIViewController
{
        
    @IBOutlet weak var firstView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textViewAddress: UITextView!
    @IBOutlet weak var textViewURL: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        mainView.userInteractionEnabled = true
        secondView.hidden = true
        
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
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(textViewAddress.text, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil)
            {
                print("Error", error)
                
                let alert = UIAlertController(title: "Problem getting address", message: "Please set another address", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                if let placemark = placemarks?.first
                {
//                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                     self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                }
                
                self.secondView.hidden = false
                self.firstView.hidden = false
            }
        })
    }
    
    @IBAction func submitAction(sender: AnyObject)
    {
        HttpsRequestManager.sharedInstance.gettingPublicUserData()
    }
    // MARK: - Keyboard methods
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
