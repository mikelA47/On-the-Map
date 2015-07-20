//
//  TabTableTableViewController.swift
//  On the Map
//
//  Created by Mikel Lizarralde Cabrejas on 1/7/15.
//  Copyright © 2015 TheUnit. All rights reserved.
//

import UIKit

class TabTableTableViewController: UITableViewController {

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "StudentMapPointCell"
        let studentMapPoint = ParseClient.sharedInstance().studentsLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)! as UITableViewCell
        
        //add full name to show on each row
        cell.textLabel!.text = studentMapPoint.firstNameLastName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().studentsLocations.count
    }
    
    //go to url - new back button at top left included in iOS9 - very nice
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().openURL(NSURL(string: ParseClient.sharedInstance().studentsLocations[indexPath.row].studentURL)!)
    }
    
    //refresh
    func reloadViewController() {
        tableView.reloadData()
    }

}
