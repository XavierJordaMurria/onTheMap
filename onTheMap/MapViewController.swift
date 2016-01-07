//
//  MapViewController.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 26/12/2015.
//  Copyright © 2015 xjm. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    var onTheMapDelegate: OnTheMapAppDelegate = (UIApplication.sharedApplication().delegate as! OnTheMapAppDelegate)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        HttpsRequestManager.sharedInstance.gettingStudentsLocation()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationSucced", name:"HTTPRequest_StudentsLocationSucced", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentsLocationFailed", name:"HTTPRequest_StudentsLocationFailed", object: nil)
        
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
    
    // MARK: - Students Location Notifications
    func studentsLocationSucced()
    {
        let studentsDataLoc: NSArray = onTheMapDelegate.studentsLocationDic["results"] as! NSArray
        
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

            mapView.addAnnotation(annotation)
        }
    }
    
    func studentsLocationFailed()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: "Failed loading data", message: "loading students location has failed for unknown reasons", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}