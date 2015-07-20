//
//  AddPinViewController.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 1/7/15.
//  Copyright © 2015 TheUnit. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    //first Stage - find location
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var backgroundFirstStage: UIView!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    var coordinates: CLLocationCoordinate2D!
    
    //second Stage - add pin
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var mapAddPin: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backgroundSecondStage: UIView!
    @IBOutlet weak var visualEffectSecondStage: UIVisualEffectView!
    //Activiy Indicator
    @IBOutlet weak var activityBackground: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Show the controls of first stage(enter location) and hide the controls of second stage(enter link)
        self.fromSecondStageToFirstStage()
        
        //keyboard return capability
        self.locationField.delegate = self
        self.linkField.delegate = self
    }
    
    //from find to submit
    func fromFirstStageToSecondStage()
    {
        self.whereLabel.hidden = true
        self.locationField.hidden = true
        self.backgroundFirstStage.hidden = true
        self.findOnTheMapButton.hidden = true
        
        self.linkField.hidden = false
        self.mapAddPin.hidden = false
        self.submitButton.hidden = false
        self.backgroundSecondStage.hidden = false
        self.visualEffectSecondStage.hidden = false
        
        self.activityBackground.hidden = true
        self.activityIndicator.hidden = true
    }
    
    //from submit to find
    func fromSecondStageToFirstStage()
    {
        self.whereLabel.hidden = false
        self.locationField.hidden = false
        self.backgroundFirstStage.hidden = false
        self.findOnTheMapButton.hidden = false
        
        self.linkField.hidden = true
        self.mapAddPin.hidden = true
        self.submitButton.hidden = true
        self.backgroundSecondStage.hidden = true
        self.visualEffectSecondStage.hidden = true
        self.activityBackground.hidden = true
        self.activityIndicator.hidden = true
    }
    
    //keyboard return - P2 MemeMe
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {

        let geoCoder: CLGeocoder = CLGeocoder()
        
        //Geocodes the location to see if places available
        geoCoder.geocodeAddressString(self.locationField.text!, completionHandler: { (places, error) -> Void in
            
            if ((error) != nil) {
                self.errorAlert("Location not found", error: "Enter another address")
            }
            else if let _ = places?[0] as CLPlacemark? {
                let placemark: CLPlacemark = places![0] as CLPlacemark
                
                //Create necessary properties
                let coordinates: CLLocationCoordinate2D = placemark.location.coordinate
                let pointAnnotation: MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinates
                
                self.fromFirstStageToSecondStage()
                
                //Add annotation to mapView
                self.mapAddPin.addAnnotation(pointAnnotation)
                
                //Situates centre with our coordinates
                self.mapAddPin.centerCoordinate = coordinates
                
                //Zoom level closer than general view but not to close
                self.mapAddPin.camera.altitude = 2000000;
                
                self.coordinates = coordinates
                
                //Keyboard returns
                self.locationField.resignFirstResponder()                
            }
        })
    }
    
    
    @IBAction func submitAddPin(sender: AnyObject) {

        if validateUrl(self.linkField.text!) == false {
            errorAlert("URL not valid", error: "Enter another URL")
        } else {
            //Post method -> new location into Parse
            self.activityIndicator.hidden = false
            self.activityBackground.hidden = false
            ParseClient.sharedInstance().posttingOneStudentInformation(self.coordinates.latitude.description, longitud: self.coordinates.longitude.description, studentAddress: self.locationField.text!, studentURL: self.linkField.text!) { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        ParseClient.sharedInstance().refresh = true
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.errorAlert("Error Adding Pin", error: errorString!)
                    })
                }
            }
        }
    }
    
    //Common error-alert message
    func errorAlert(title: String, error: String) {
        let controller: UIAlertController = UIAlertController(title: title, message: error, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    //Check before posting
    func validateUrl(url: String) -> Bool {
        //create common characters pattern to compare
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let _ = url.rangeOfString(pattern, options: .RegularExpressionSearch){
            return true
        }
        return false
    }
}