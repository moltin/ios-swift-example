//
//  CartViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 15/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin
import SwiftSpinner

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CartTableViewCellDelegate {
    
    fileprivate let CART_CELL_REUSE_IDENTIFIER = "CartTableViewCell"
    
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var totalLabel:UILabel?
    @IBOutlet weak var checkoutButton:UIButton?
    
    fileprivate var cartData:NSDictionary?
    fileprivate var cartProducts:NSDictionary?
    
    fileprivate let BILLING_ADDRESS_SEGUE_IDENTIFIER = "showBillingAddress"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Cart"
        
        totalLabel?.text = ""
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        refreshCart()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshCart() {
        SwiftSpinner.show("Updating cart")
        
        // Get the cart contents from Moltin API
        Moltin.sharedInstance().cart.getContentsWithsuccess({ (response) -> Void in
            // Got cart contents succesfully!
            // Set local var's
            self.cartData = response as NSDictionary?
            //println(self.cartData)
            
            self.cartProducts = self.cartData?.value(forKeyPath: "result.contents") as? NSDictionary
            
            // Reset cart total
            if let cartPriceString:NSString = self.cartData?.value(forKeyPath: "result.totals.post_discount.formatted.with_tax") as? NSString {
                self.totalLabel?.text = cartPriceString as String
                
            }
            
            // And reload table of cart items...
            self.tableView?.reloadData()
            
            // Hide loading UI
            SwiftSpinner.hide()
            
            // If there's < 1 product in the cart, disable the checkout button
            self.checkoutButton?.isEnabled = (self.cartProducts != nil && (self.cartProducts?.count)! > 0)

            }, failure: { (response, error) -> Void in
                // Something went wrong; hide loading UI and warn user
                SwiftSpinner.hide()

                AlertDialog.showAlert("Error", message: "Couldn't load cart", viewController: self)
                print("Something went wrong...")
                print(error)
        })
        
        
        
    }
    
    // MARK: - TableView Data source & Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (cartProducts != nil) {
            return cartProducts!.allKeys.count
        }
        
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CART_CELL_REUSE_IDENTIFIER, for: indexPath) as! CartTableViewCell
        
        let row = (indexPath as NSIndexPath).row
        
        let product:NSDictionary = cartProducts!.allValues[row] as! NSDictionary
        
        cell.setItemDictionary(product)
        
        cell.productId = cartProducts!.allKeys[row] as? String
        
        cell.delegate = self
        
        
        return cell
    }
    
    
    
    func tableView(_ _tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            
            if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
                cell.separatorInset = UIEdgeInsets.zero
            }
            if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
                cell.layoutMargins = UIEdgeInsets.zero
            }
            if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
                cell.preservesSuperviewLayoutMargins = false
            }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete){
            // Remove the item from the cart.
            removeItemFromCartAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    fileprivate func removeItemFromCartAtIndex(_ index: Int) {
        // Get item ID...
        let selectedProductId = cartProducts!.allKeys[index] as? String
        
        SwiftSpinner.show("Updating cart")

        
        // And remove it from the cart...
        Moltin.sharedInstance().cart.removeItem(withId: selectedProductId, success: { (response) -> Void in
            // Completed item removal - refresh cart hide loading UI
            self.refreshCart()

            SwiftSpinner.hide()
            
            
            }, failure: { (response, error) -> Void in
                // Removal failed - hide loading UI and warn the user
                SwiftSpinner.hide()
                
                AlertDialog.showAlert("Error", message: "Couldn't update cart", viewController: self)
                print("Something went wrong...")
                print(error)
        })
    }
    
    // MARK: - Cell delegate
    func cartTableViewCellSetQuantity(_ cell: CartTableViewCell, quantity: Int) {
        // The cell's quantity's been updated by the stepper control - tell the Moltin API and refresh the cart too.
        // If quantity is zero, the Moltin API automagically knows to remove the item from the cart
        
        // Loading UI..
        SwiftSpinner.show("Updating quantity")
        
        // Update to new quantity value...
        Moltin.sharedInstance().cart.updateItem(withId: cell.productId!, parameters: ["quantity": quantity], success: { (response) -> Void in
            // Update succesful, refresh cart
            self.refreshCart()

            SwiftSpinner.hide()
            
            
            }, failure: { (response, error) -> Void in
                // Something went wrong; hide loading UI and warn user
                SwiftSpinner.hide()
                
                AlertDialog.showAlert("Error", message: "Couldn't update cart", viewController: self)
                print("Something went wrong...")
                print(error)
        })
        
        
    }
    
    // MARK: - Checkout button
    @IBAction func checkoutButtonClicked(_ sender: AnyObject) {
        performSegue(withIdentifier: BILLING_ADDRESS_SEGUE_IDENTIFIER, sender: self)
    }
    
}

