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
    
    private let PRODUCTS_LIST_SEGUE_IDENTIFIER = "productsListSegue"
    
    private var selectedCollectionDict:NSDictionary?

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
    
    // MARK: - TableView Data source & Delegate
    
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
        
        cell.setCollectionDictionary(collectionDictionary)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedCollectionDict = collections?.objectAtIndex(indexPath.row) as? NSDictionary

        performSegueWithIdentifier(PRODUCTS_LIST_SEGUE_IDENTIFIER, sender: self)

        
    }
    
    func tableView(_tableView: UITableView,
        willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            if cell.respondsToSelector("setSeparatorInset:") {
                cell.separatorInset = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setLayoutMargins:") {
                cell.layoutMargins = UIEdgeInsetsZero
            }
            if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
                cell.preservesSuperviewLayoutMargins = false
            }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == PRODUCTS_LIST_SEGUE_IDENTIFIER {
            // Set up products list view!
            let newViewController = segue.destinationViewController as! ProductListTableViewController
            
            newViewController.title = selectedCollectionDict!.valueForKey("title") as? String
            newViewController.collectionId = selectedCollectionDict!.valueForKeyPath("id") as? String
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

