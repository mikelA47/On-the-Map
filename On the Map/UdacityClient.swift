//
//  UdacityClient.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 29/4/15.
//  Copyright (c) 2015 TheUnit. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    

    /* Parameters used */
    var uniqueKey: String = ""
    var firstName: String = ""
    var lastName: String = ""
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //received from LogIn screen uasername and password
    func logInUdacity(username :String, password :String, completionHandler: (success: Bool,errorLogIn: String?) -> Void) {
        
        let HTTPbody = "{\"udacity\": {\"username\":\""+username+"\", \"password\": \""+password+"\"}}"
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = HTTPbody.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorLogIn: error!.description)
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //Parsing newData
            //swift 2.0 need to use try! still not quit confortable with do-try-cacth java stylish
            //to be done properly when possible
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let userKey = parsedResult["account"]?.valueForKey("key") as? String {
                self.uniqueKey = userKey
                completionHandler(success: true, errorLogIn: nil)
            }
            else {
                completionHandler(success: false, errorLogIn: "Username or password are incorrect")
            }
        }
        task!.resume() //swift 2.0 -> task!.resume() instead of task.resume()
    }
    
    //after receiving the OK from udacity with the unique Key of that user we collect basic information
    func setFirstLastNameUsingUniqueKey(completionHandler: (success: Bool, errorSet: String?) -> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string :"https://www.udacity.com/api/users/\(self.uniqueKey)")!)

        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {

                completionHandler(success: false, errorSet: error!.description)
            }

            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            //Parsing new data
            //swift 2.0 need to use try! still not quit confortable with do-try-cacth java stylish
            //to be done properly when possible
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary

            if let firstName = parsedResult["user"]?.valueForKey("first_name") as? String {
                self.firstName = firstName

            }
            else {
                //send error
                completionHandler(success: false, errorSet: "Impossible to recover First Name or Last Name")

            }
            if let lastName = parsedResult["user"]?.valueForKey("last_name") as? String {
                self.lastName = lastName
            }
            else {
                //send error
                completionHandler(success: false, errorSet: "Impossible to recover First Name or Last Name")
            }
            //If we are here it´s because everything went right! 
            completionHandler(success: true, errorSet: nil)
        }
        task!.resume() //swift 2.0 -> task!.resume() instead of task.resume()
    }
    
    func logOut(completionHandler: (success: Bool,errorLogOut: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, errorLogOut: error!.description)
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            completionHandler(success: true, errorLogOut: nil)
        }
        task!.resume()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
}