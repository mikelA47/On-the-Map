//
//  TabMapViewController.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 1/7/15.
//  Copyright © 2015 TheUnit. All rights reserved.
//

import UIKit
import MapKit

class TabMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Zoom level
        self.mapView?.camera.altitude = 50000000;
        
        //hardcode initial map position to show Bilbao in the centre
        //Bilbao 43.266574, -2.934251
        self.mapView?.centerCoordinate = CLLocationCoordinate2D(latitude: 43.266574, longitude: -2.934251)

        //required
        self.mapView.delegate = self

        //Put pins on map
        self.reloadViewController()

    }
    
    //go to url - new back button at top left included in iOS9 - very nice
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            UIApplication.sharedApplication().openURL(NSURL(string: view.annotation!.subtitle!!)!)
    }
    
    //Creates "tappable" view to the annotation so you can tap to access url
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapAnnotation")
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        return view
    }
    
    //refresh data
    func reloadViewController() {
        
        //load students info
        let results = ParseClient.sharedInstance().studentsLocations
        
        //We only have basic student info so we must
        //go through every student to create annotation with their names, locations and url
        for result in results {
            let annotation = MKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)

            annotation.coordinate = location
            annotation.title = result.firstNameLastName
            annotation.subtitle = result.studentURL
            
            //Adds annotation to the mapView
            self.mapView.addAnnotation(annotation)
        }
    }
}
