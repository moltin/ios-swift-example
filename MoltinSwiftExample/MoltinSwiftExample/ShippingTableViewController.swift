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
    
    fileprivate let SHIPPING_CELL_REUSE_IDENTIFIER = "shippingMethodCell"
    fileprivate let PAYMENT_SEGUE = "paymentSegue"

    fileprivate var shippingMethods:NSArray?
    
    // It needs some pass-through variables too...
    var emailAddress:String?
    var billingDictionary:Dictionary<String, String>?
    var shippingDictionary:Dictionary<String, String>?
    
    fileprivate var selectedShippingMethodSlug = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        if (shippingMethods == nil) {
            // get shipping methods for the shipping address we've been passed...
            SwiftSpinner.show("Loading Shipping Methods")

            
            Moltin.sharedInstance().cart.checkoutWithsuccess({ (response) -> Void in
                // Success - let's extract shipping methods...
                SwiftSpinner.hide()
                
                // Shipping methods are stored in an array at key path result.shipping.methods
                
                self.shippingMethods = (NSDictionary(dictionary: response!).value(forKeyPath: "result.shipping.methods") as! NSArray)
                
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if (shippingMethods != nil) {
            return shippingMethods!.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SHIPPING_CELL_REUSE_IDENTIFIER, for: indexPath) as! ShippingMethodTableViewCell

        // Configure the cell...
        let shippingMethod = shippingMethods?.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        cell.methodNameLabel?.text = (shippingMethod.value(forKey: "title") as! String)
        cell.costLabel?.text = (shippingMethod.value(forKeyPath: "price.data.formatted.with_tax") as! String)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // User has chosen their shipping method - let's continue the checkout...
        let shippingMethod = shippingMethods?.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
        selectedShippingMethodSlug = (shippingMethod.value(forKey: "slug") as! String)
        
        // Continue!
        performSegue(withIdentifier: PAYMENT_SEGUE, sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == PAYMENT_SEGUE {
            // Setup payment view...
            let paymentView = segue.destination as! PaymentViewController
            paymentView.billingDictionary = self.billingDictionary!
            paymentView.shippingDictionary = self.shippingDictionary!
            paymentView.emailAddress = self.emailAddress!
            paymentView.selectedShippingMethodSlug = self.selectedShippingMethodSlug
        }
        
    }

}
