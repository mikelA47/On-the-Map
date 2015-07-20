//
//  StudentInformation.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 4/5/15.
//  Copyright (c) 2015 TheUnit. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    //No need of more information
    var firstNameLastName = ""
    var latitude = 0.0 //floating point suggested
    var longitude = 0.0 //floating point suggested
    var studentURL = ""
    
    //inicialize from a dictionary
    init(dictionary: [String: AnyObject]) {
        var firstName = ""
        var lastName = ""
        
        if let firstName_ = dictionary["firstName"] as? String {
            firstName = firstName_
        }
        if let lastName_ = dictionary["lastName"] as? String {
            lastName = lastName_
        }
        
        self.firstNameLastName = firstName + " " + lastName
        
        if let latitude = dictionary["latitude"] as? Double {
            self.latitude = latitude
        }
        if let longitude = dictionary["longitude"] as? Double {
            self.longitude = longitude
        }
        
        if let studentURL = dictionary["mediaURL"] as? String {
            self.studentURL = studentURL
        }
        
    }
}
