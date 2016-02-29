//
//  DataModel.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 14/02/2016.
//  Copyright © 2016 xjm. All rights reserved.
//

import Foundation

class  DataModel
{
    static let sharedInstance = DataModel()
    
    var udacityStudentStruct = StudentModel()
    
    var studentsLocationArray: [StudentModel] = []
    
    func verifyUrl (urlString: String?) -> Bool
    {
        //Check for nil
        if let urlString = urlString
        {
            // create NSURL instance
            if let url = NSURL(string: urlString)
            {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
}
