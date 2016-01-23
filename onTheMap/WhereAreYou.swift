    //
//  WhereAreYou.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 23/01/2016.
//  Copyright © 2016 xjm. All rights reserved.
//

import UIKit

class WhereAreYou: UIViewController
{
        
    @IBOutlet var mainView: UIView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
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
    
    // MARK: - action methods
    @IBAction func cancelButton(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: { () -> Void in })
    }

    @IBAction func findOnMapButton(sender: AnyObject)
    {
        
    }
    
    // MARK: - Keyboard methods
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
