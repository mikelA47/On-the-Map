//
//  ParseClient.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 29/4/15.
//  Copyright (c) 2015 TheUnit. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    let ApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let ApplicationID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    var studentsLocations = [StudentBasic]()
    
    var refresh = false
    
    func gettingStudentLocations(completionHandler: (success: Bool,errorGetting:String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(self.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(self.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(success: false, errorGetting: error?.description)
            }
            
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!,options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let results = parsedResult["results"] as? [[String: AnyObject]] {
                self.studentsLocations.removeAll(keepCapacity: true)
                
                for result in results {
                    print("*,")
                    self.studentsLocations.append(StudentBasic(dictionary: result))
                }
                
                self.refresh = true
                print("****")
                completionHandler(success: true, errorGetting: nil)
            }
            else {
                completionHandler(success: false, errorGetting: "Could not find any results")
            }
            
        }
        print("***")
        task!.resume()
    }
    
    func posttingOneStudentInformation(latitude: String, longitud: String, studentAddress: String, studentURL: String, completionHandler: (success: Bool, errorPosting: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(self.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(self.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().uniqueKey)\", \"firstName\": \"\(UdacityClient.sharedInstance().firstName)\", \"lastName\": \"\(UdacityClient.sharedInstance().lastName)\",\"mapString\": \"\(studentAddress)\", \"mediaURL\": \"\(studentURL)\",\"latitude\": \(latitude), \"longitude\": \(longitud)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, errorPosting: "Error postting student information")
            }
            else {
                completionHandler(success: true, errorPosting: nil)
            }
        }
        task!.resume()
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}