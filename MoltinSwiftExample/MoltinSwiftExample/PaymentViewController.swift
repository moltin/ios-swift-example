//
//  PaymentViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 20/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin
import SwiftSpinner

class PaymentViewController: UITableViewController, TextEntryTableViewCellDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Replace this constant with your store's payment gateway slug
    let PAYMENT_GATEWAY = "dummy"
    
    let PAYMENT_METHOD = "purchase"
    
    // It needs some pass-through variables too...
    var emailAddress:String?
    var billingDictionary:Dictionary<String, String>?
    var shippingDictionary:Dictionary<String, String>?
    var selectedShippingMethodSlug:String?
    var cardNumber:String?
    var cvvNumber:String?
    var selectedMonth:String?
    var selectedYear:String?
    
    let CONTINUE_CELL_ROW_INDEX = 3
    
    let cardNumberIdentifier = "cardNumber"
    let cvvNumberIdentifier = "cvvNumber"
    
    let datePicker = UIPickerView()
    var monthsArray = Array<Int>()
    var yearsArray = Array<String>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.delegate = self
        datePicker.dataSource = self
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.opaque = true
        
        // Populate months
        for i in 1...12 {
            monthsArray.append(i)
        }
        
        // Populate years
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
        let currentYear = components.year
        let currentShortYear = (NSString(format: "%d", currentYear).substringFromIndex(2) as NSString)
        let shortYearNumber = currentShortYear.intValue
        let maxYear = shortYearNumber + 5
        for i in shortYearNumber...maxYear {
            let shortYear = (NSString(format: "%d", i).substringFromIndex(2) as NSString)
            yearsArray.append(shortYear as String)
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
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == CONTINUE_CELL_ROW_INDEX {
            let cell = tableView.dequeueReusableCellWithIdentifier(CONTINUE_BUTTON_CELL_IDENTIFIER, forIndexPath: indexPath) as! ContinueButtonTableViewCell
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TEXT_ENTRY_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! TextEntryTableViewCell
        
        // Configure the cell...
        
        switch (indexPath.row) {
        case 0:
            cell.textField?.placeholder = "Card number"
            cell.textField?.keyboardType = UIKeyboardType.NumberPad
            cell.cellId = cardNumberIdentifier
            
        case 1:
            cell.textField?.placeholder = "CVV number"
            cell.textField?.keyboardType = UIKeyboardType.NumberPad
            cell.cellId = cvvNumberIdentifier
        case 2:
            cell.textField?.placeholder = "Expiry date"
            cell.textField?.inputAccessoryView = datePicker
            cell.cellId = "expiryDate"
            cell.hideCursor()
        default:
            cell.textField?.placeholder = ""
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == CONTINUE_CELL_ROW_INDEX {
            // Pay!
            
            completeOrder()
        }
    }
    
    //MARK: - Text field Cell Delegate
    func textEnteredInCell(cell: TextEntryTableViewCell, cellId:String, text: String) {
        let cellId = cell.cellId!
        
        
    }
    
    
    //MARK: - Date picker delegate and data source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return monthsArray.count
            
        } else {
            return yearsArray.count
            
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        if component == 0 {
            return String(format: "%d", monthsArray[row])
            
        } else {
            return yearsArray[row]
            
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.tableView.reloadData()
        
    }
    
    // MARK: - Moltin Order API
    private func completeOrder() {
        
        // Show some loading UI...
        SwiftSpinner.show("Completing Purchase")
        
        let firstName = billingDictionary!["first_name"]! as String
        let lastName = billingDictionary!["last_name"]! as String
        
        let orderParameters = [
            "customer": ["first_name": firstName,
                "last_name":  lastName,
                "email":      emailAddress!],
            "shipping": self.selectedShippingMethodSlug!,
            "gateway": PAYMENT_GATEWAY,
            "bill_to": self.billingDictionary!,
            "ship_to": self.shippingDictionary!
            ] as [NSObject: AnyObject]
        
        Moltin.sharedInstance().cart.orderWithParameters(orderParameters, success: { (response) -> Void in
            // Order succesful
            println("Order succeeded: \(response)")
            
            // Extract the Order ID so that it can be used in payment too...
            let orderId = (response as NSDictionary).valueForKeyPath("result.id") as! String
            println("Order ID: \(orderId)")

            let paymentParameters = ["data": ["number": self.cardNumber!,
                "expiry_month": self.selectedMonth!,
                "expiry_year":  self.selectedYear!,
                "cvv":          self.cvvNumber!
                ]] as [NSObject: AnyObject]
            
            Moltin.sharedInstance().checkout.paymentWithMethod(self.PAYMENT_METHOD, order: orderId, parameters: paymentParameters, success: { (response) -> Void in
                // Payment successful...
                println("Payment successful: \(response)")
                SwiftSpinner.hide()
                
                AlertDialog.showAlert("Order Successful", message: "Your order has been succesful, congratulations", viewController: self)
                
                self.navigationController?.popToRootViewControllerAnimated(true)

                
                }) { (response, error) -> Void in
                    // Payment error
                    println("Payment error: \(error)")
                    SwiftSpinner.hide()
                    AlertDialog.showAlert("Payment Failed", message: "Payment failed - please try again", viewController: self)


            }
            
            
            }) { (response, error) -> Void in
                // Order failed
                println("Order error: \(error)")
                SwiftSpinner.hide()
                
                AlertDialog.showAlert("Order Failed", message: "Order failed - please try again", viewController: self)

        }
        
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
    }
    
}
