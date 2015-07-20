//
//  TabBarViewController.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 1/7/15.
//  Copyright © 2015 TheUnit. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    @IBOutlet weak var refreshButtonView: UIBarButtonItem!
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        self.refreshData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //if refresh is true the reload the info, once done we put refresh to false to avoid innecesary reloads
        if ParseClient.sharedInstance().refresh {
            ParseClient.sharedInstance().refresh = false
            self.refreshData()
        }
    }
    
    @IBAction func logOutButton(sender: AnyObject) {
        UdacityClient.sharedInstance().logOut() { (success, errorLogOut) in
            if (success == true) {
                print("Log Out...")
                dispatch_async(dispatch_get_main_queue(), {
                    let newController = self.storyboard!.instantiateViewControllerWithIdentifier("logInScreen") as UIViewController
                    self.presentViewController(newController, animated: true, completion: nil)
                })
            }
            else {
                print("Log Out Error")
            }
        }
    }
    func refreshData() {
        //call get method -> students info
        ParseClient.sharedInstance().gettingStudentLocations() { (success, errorString) in
            if !success {
                dispatch_async(dispatch_get_main_queue(), {
                    let controller: UIAlertController = UIAlertController(title: "Error", message: "Error refreshing the student locations. Please tap to try again.", preferredStyle: .Alert)
                    controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    if let viewControllers = self.viewControllers {
                        //access both tab´s with self viewControllers 0 -> left tab, 1 -> rigth tab 
                        //but have problems parsing so I used a for loop to access everyone
                        //first iteracy map, second iteracy table
                        var cont = 1
                        for viewController in viewControllers {
                            if cont == 1 {
                                (viewController as! TabMapViewController).reloadViewController()
                                cont++
                            }
                            else {
                                (viewController as! TabTableTableViewController).reloadViewController()
                                cont=1
                            }
                        }
                    }
                })
            }
        }
    }
}
