//
//  studentModel.swift
//  onTheMap
//
//  Created by Xavier Jorda Murria on 18/12/2015.
//  Copyright © 2015 xjm. All rights reserved.
//

import Foundation

struct StudentModel
{
    var accountRegistered: Bool?
    var accountKey: String?
    var sessionID: String?
    var sessionExpiration: String?
    
    var createdAt: String?
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var objectId: String?
    var uniqueKey: String?
    var updatedAt: String?

    init(){}
    
    init(studentsLoctionProperties:NSDictionary)
    {
        guard   let creAt = studentsLoctionProperties["createdAt"]  as? String,
            let fName = studentsLoctionProperties["firstName"]  as? String,
            let lName = studentsLoctionProperties["lastName"]   as? String,
            let ltd = studentsLoctionProperties["latitude"]     as? Double,
            let lngt = studentsLoctionProperties["longitude"]   as? Double,
            let mString = studentsLoctionProperties["mapString"]    as? String,
            let mURL = studentsLoctionProperties["mediaURL"]    as? String,
            let obID = studentsLoctionProperties["objectId"]    as? String,
            let unkey = studentsLoctionProperties["uniqueKey"]  as? String,
            let upAt = studentsLoctionProperties["updatedAt"]   as? String
        else
        {
            return
        }
        
        createdAt   = creAt
        firstName   = fName
        lastName    = lName
        latitude    = ltd
        longitude   = lngt
        mapString   = mString
        mediaURL    = mURL
        objectId    = obID
        uniqueKey   = unkey
        updatedAt   = upAt 
    }
//    init(studentsLoctionProperties:NSArray)
//    {
//        guard   let creAt = studentsLoctionProperties.createdAt  as? String,
//            let fName = studentsLoctionProperties["firstName"]  as? String,
//            let lName = studentsLoctionProperties["lastName"]   as? String,
//            let ltd = studentsLoctionProperties["latitude"]     as? Double,
//            let lngt = studentsLoctionProperties["longitude"]   as? Double,
//            let mString = studentsLoctionProperties["mapString"]    as? String,
//            let mURL = studentsLoctionProperties["mediaURL"]    as? String,
//            let obID = studentsLoctionProperties["objectId"]    as? String,
//            let unkey = studentsLoctionProperties["uniqueKey"]  as? String,
//            let upAt = studentsLoctionProperties["updatedAt"]   as? String
//            else
//        {
//            return
//        }
//        
//        createdAt   = creAt
//        firstName   = fName
//        lastName    = lName
//        latitude    = ltd
//        longitude   = lngt
//        mapString   = mString
//        mediaURL    = mURL
//        objectId    = obID
//        uniqueKey   = unkey
//        updatedAt   = upAt
//    }

}
