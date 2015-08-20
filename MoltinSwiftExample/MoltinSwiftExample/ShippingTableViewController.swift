//
//  ShippingTableViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 17/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin
import SwiftSpinner

class ShippingTableViewController: UITableViewController {
    
    private let SHIPPING_CELL_REUSE_IDENTIFIER = "shippingMethodCell"
    private let PAYMENT_SEGUE = "paymentSegue"

    private var shippingMethods:NSArray?
    
    // It needs some pass-through variables too...
    var emailAddress:String?
    var billingDictionary:Dictionary<String, String>?
    var shippingDictionary:Dictionary<String, String>?
    
    var selectedShippingMethodSlug = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if (shippingMethods == nil) {
            // get shipping methods for the shipping address we've been passed...
            SwiftSpinner.show("Loading Shipping Methods")

            
            Moltin.sharedInstance().cart.checkoutWithsuccess({ (response) -> Void in
                // Success - let's extract shipping methods...
                SwiftSpinner.hide()
                
                // Shipping methods are stored in an array at key path result.shipping.methods
                
                self.shippingMethods = ((response as NSDictionary).valueForKeyPath("result.shipping.methods") as! NSArray)
                
                self.tableView.reloadData()
                
            }, failure: { (response, error) -> Void in
                // Something went wrong - let's warn the user...
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if (shippingMethods != nil) {
            return shippingMethods!.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SHIPPING_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! ShippingMethodTableViewCell

        // Configure the cell...
        let shippingMethod = shippingMethods?.objectAtIndex(indexPath.row) as! NSDictionary
        cell.methodNameLabel?.text = (shippingMethod.valueForKey("title") as! String)
        cell.costLabel?.text = (shippingMethod.valueForKeyPath("price.data.formatted.with_tax") as! String)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // User has chosen their shipping method - let's continue the checkout...
        let shippingMethod = shippingMethods?.objectAtIndex(indexPath.row) as! NSDictionary
        selectedShippingMethodSlug = (shippingMethod.valueForKey("slug") as! String)
        
        // Continue!
        performSegueWithIdentifier(PAYMENT_SEGUE, sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == PAYMENT_SEGUE {
            // Setup payment view...
            let paymentView = segue.destinationViewController as! PaymentViewController
            paymentView.billingDictionary = self.billingDictionary
            paymentView.shippingDictionary = self.shippingDictionary
            paymentView.emailAddress = self.emailAddress
            paymentView.selectedShippingMethodSlug = self.selectedShippingMethodSlug
        }
        
    }

}
