//
//  CollectionsViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 15/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin
import SwiftSpinner

class CollectionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView?
    
    private var collections:NSArray?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Collections"
        
        // Show loading UI
        SwiftSpinner.show("Loading Collections")
        
        // Get collections, async
        Moltin.sharedInstance().collection.listingWithParameters(["status": NSNumber(int: 1), "limit": NSNumber(int: 20)], success: { (response) -> Void in
            // We have collections - show them!
            SwiftSpinner.hide()
            
            self.collections = response["result"] as? NSArray
            
            self.tableView?.reloadData()
            
        }) { (response, error) -> Void in
            // Something went wrong; hide loading UI and display warning.
            SwiftSpinner.hide()

        }
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collections != nil {
            return collections!.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CollectionCell", forIndexPath: indexPath) as! CollectionTableViewCell
        
        let row = indexPath.row
        
        let collectionDictionary = collections?.objectAtIndex(row) as! NSDictionary
        
        cell.collectionLabel?.text = collectionDictionary.valueForKey("title") as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

