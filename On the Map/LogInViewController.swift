//
//  LogInViewController.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 27/5/15.
//  Copyright (c) 2015 TheUnit. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController,UITextFieldDelegate {

    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        self.email.delegate = self
        self.password.delegate = self
        //self.email.resignFirstResponder()
        //self.password.resignFirstResponder()

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func singUpButton(sender: UIButton) {
        //go to udacity signup webpage - new back button at top left included in iOS9
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }

    @IBAction func loginButton(sender: UIButton) {
        //beforehand...
        if ((self.email.text == "")||(self.password.text == "")) {
            self.errorLabel.text = "Please enter a username and password"
        }
        else {
            self.errorLabel.text = "Stablishing connection..."
            UdacityClient.sharedInstance().logInUdacity(self.email.text!, password: self.password.text!) { (success, errorLogIn) in
                if (success == true) {
                    UdacityClient.sharedInstance().setFirstLastNameUsingUniqueKey() { (success, errorLogIn) in
                        if (success == true) {
                            //if everything allright try to get students info from Parse
                            ParseClient.sharedInstance().gettingStudentLocations() { (success, errorLogIn) in
                                if (success == true) {
                                    print("Students loaded...")
                                    self.completeLogIn()
                                }
                                else {
                                    //print error received from ParseClient
                                    self.showError(errorLogIn)
                                }
                            }
                        }
                        else {
                            //print error received from UdacityClietn
                            self.showError(errorLogIn)
                        }
                    }
                }
                else {
                    //print error received from UdacityClient
                    self.showError(errorLogIn)
                }
            }
            
        }
    }
    
    func completeLogIn()
    {
        self.errorLabel.text = "You are in!!!"
        dispatch_async(dispatch_get_main_queue(), {
            let newController = self.storyboard!.instantiateViewControllerWithIdentifier("whereToLandFromLogIn") as! UINavigationController
            //call NavigationController
            //Storyboard explanation
            //we must add a NavigationController to the TabBarController to be able to add a Nav Bar to the top of every tab
            //That´s why we land into the NavigationController instead of the 
            //TabBarNavigationController - OnTheMap
            self.presentViewController(newController, animated: true, completion: nil)
        })
    }
    
    //show errors received from UdacityClient and ParseClient
    func showError(errorLogIn: String?)
    {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorLogIn = errorLogIn {
                self.errorLabel.text = errorLogIn
            }
        })
    }
}
