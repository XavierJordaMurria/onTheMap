//
//  MapViewController.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 26/12/2015.
//  Copyright © 2015 xjm. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    let uiBusy = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var onTheMapDelegate: OnTheMapAppDelegate = (UIApplication.sharedApplication().delegate as! OnTheMapAppDelegate)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        HttpsRequestManager.sharedInstance.gettingStudentsLocation()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationSucceed", name:"HTTPRequest_StudentsLocationSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationFailed", name:"HTTPRequest_StudentsLocationFailed", object: nil)
        
        //Log Out Notifications Listener
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutSucceed", name:"HTTPRequest_LogOutSucceed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutSucceed", name:"HTTPRequest_LogOutFailed", object: nil)
        
        // 1
        let location = CLLocationCoordinate2D(
            latitude: 51.50007773,
            longitude: -0.1246402
        )
        // 2
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        //3
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Big Ben"
        annotation.subtitle = "London"
        mapView.addAnnotation(annotation)
    }
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
    
    // MARK: - Students Location Notifications
    func studentsLocationSucceed()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.uiBusy.stopAnimating()
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshButton:")
            self.navigationItem.rightBarButtonItem = refreshButton
        })
        
        //clean the mapView for the new studentsLocations
        mapView.removeAnnotations(mapView.annotations)
        
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        let studentsDataLoc: NSArray = onTheMapDelegate.studentsLocationDic["results"] as! NSArray
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        for value in studentsDataLoc
        {
            let location = CLLocationCoordinate2D(
                latitude: value["latitude"] as! Double,
                longitude: value["longitude"] as! Double
            )
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            
            var name:String = ""
            
            if let first = value["firstName"] as! String?
            {
                // this code will be called
                name = "\(first) "
                
                if let last = value["lastName"] as! String?
                {
                    name = "\(name) \(last)"
                }
            }
            
            annotation.title = name
            
            if let pinURL = value["mediaURL"] as! String?
            {
                 annotation.subtitle = pinURL
            }

            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        mapView.addAnnotations(annotations)
        
        mapView.reloadInputViews()
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
    
    // MARK: - MKMapViewDelegate methods
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else
        {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView
        {
            let app = UIApplication.sharedApplication()
            
            if let toOpen = view.annotation?.subtitle!
            {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
}