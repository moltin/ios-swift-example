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
    fileprivate let PAYMENT_GATEWAY = "dummy"
    
    fileprivate let PAYMENT_METHOD = "purchase"
    
    // It needs some pass-through variables too...
    var emailAddress:String?
    var billingDictionary:Dictionary<String, String>?
    var shippingDictionary:Dictionary<String, String>?
    var selectedShippingMethodSlug:String?
    fileprivate var cardNumber:String?
    fileprivate var cvvNumber:String?
    fileprivate var selectedMonth:String?
    fileprivate var selectedYear:String?
    
    fileprivate let CONTINUE_CELL_ROW_INDEX = 3
    
    fileprivate let cardNumberIdentifier = "cardNumber"
    fileprivate let cvvNumberIdentifier = "cvvNumber"
    
    fileprivate let datePicker = UIPickerView()
    fileprivate var monthsArray = Array<Int>()
    fileprivate var yearsArray = Array<String>()
    
    // Validation constants
    // Apparently, no credit cards have under 12 or over 19 digits... http://validcreditcardnumbers.info/?p=9
    let MAX_CVV_LENGTH = 4
    let MIN_CARD_LENGTH = 12
    let MAX_CARD_LENGTH = 19
    
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        
        datePicker.delegate = self
        datePicker.dataSource = self
        datePicker.backgroundColor = UIColor.white
        datePicker.isOpaque = true
        
        // Populate months
        for i in 1...12 {
            monthsArray.append(i)
        }
        
        // Populate years
        let components = (Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: Date())
        let currentYear = components.year
        let currentShortYear = (NSString(format: "%d", currentYear!).substring(from: 2) as NSString)
        selectedYear = String(format: "%d", currentYear!)

        let shortYearNumber = currentShortYear.intValue
        let maxYear = shortYearNumber + 5
        for i in shortYearNumber...maxYear {
            let shortYear = NSString(format: "%d", i)
            yearsArray.append(shortYear as String)
        }
             
    }
    
    fileprivate func jumpToCartView(_ presentSuccess: Bool) {
        for controller in self.navigationController!.viewControllers {
            if controller is CartViewController {
                self.navigationController!.popToViewController(controller , animated: true)
                
                if presentSuccess {
                    AlertDialog.showAlert("Order Successful", message: "Your order has been succesful, congratulations", viewController: controller )

                }
            }
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
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == CONTINUE_CELL_ROW_INDEX {
            let cell = tableView.dequeueReusableCell(withIdentifier: CONTINUE_BUTTON_CELL_IDENTIFIER, for: indexPath) as! ContinueButtonTableViewCell
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TEXT_ENTRY_CELL_REUSE_IDENTIFIER, for: indexPath) as! TextEntryTableViewCell
        
        // Configure the cell...
        
        switch ((indexPath as NSIndexPath).row) {
        case 0:
            cell.textField?.placeholder = "Card number"
            cell.textField?.keyboardType = UIKeyboardType.numberPad
            cell.cellId = cardNumberIdentifier
            cell.textField?.text = cardNumber
        case 1:
            cell.textField?.placeholder = "CVV number"
            cell.textField?.keyboardType = UIKeyboardType.numberPad
            cell.cellId = cvvNumberIdentifier
            cell.textField?.text = cvvNumber
        case 2:
            cell.textField?.placeholder = "Expiry date"
            cell.textField?.inputView = datePicker
            cell.textField?.setDoneInputAccessoryView()

            cell.cellId = "expiryDate"
            
            if (selectedYear != nil) && (selectedMonth != nil) {
                let shortYearNumber = (selectedYear! as NSString).intValue
                let shortYear = (NSString(format: "%d", shortYearNumber).substring(from: 2) as NSString)
                let formattedDate = String(format: "%@/%@", selectedMonth!, shortYear)
                cell.textField?.text = formattedDate
            }
            
            cell.hideCursor()
        default:
            cell.textField?.placeholder = ""
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath as NSIndexPath).row == CONTINUE_CELL_ROW_INDEX {
            // Pay! (after a little validation)
            
            if validateData() {
                completeOrder()
            }
            
        }
    }
    
    //MARK: - Text field Cell Delegate
    func textEnteredInCell(_ cell: TextEntryTableViewCell, cellId:String, text: String) {
        let cellId = cell.cellId!
        
        if cellId == cardNumberIdentifier {
            cardNumber = text
        }
        
        if cellId == cvvNumberIdentifier {
            cvvNumber = text
        }
        
    }
    
    
    //MARK: - Date picker delegate and data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return monthsArray.count
            
        } else {
            return yearsArray.count
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == 0 {
            return String(format: "%d", monthsArray[row])
            
        } else {
            return yearsArray[row]
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            // Month selected
            selectedMonth = String(format: "%d", monthsArray[row])
            
        } else {
            // Year selected
            // WARNING: The following code won't work past year 2100.
            selectedYear = "20" + yearsArray[row]
        }
        
        self.tableView.reloadData()
        
    }
    
    // MARK: - Data validation
    fileprivate func validateData() -> Bool {
        // Check CVV is all numeric, and < max length
        if cvvNumber == nil || !cvvNumber!.isNumericString() || (cvvNumber!).characters.count > MAX_CVV_LENGTH {
            AlertDialog.showAlert("Invalid CVV Number", message: "Please check the CVV number you entered and try again.", viewController: self)
            
            return false
        }
        
        // Check card number is all numeric, and < max length but also > min length
        if cardNumber == nil || !cardNumber!.isNumericString() || (cardNumber!).characters.count > MAX_CARD_LENGTH || (cardNumber!).characters.count < MIN_CARD_LENGTH {
            AlertDialog.showAlert("Invalid Card Number", message: "Please check the card number you entered and try again.", viewController: self)

            return false
        }
        
        return true
    }
    
    // MARK: - Moltin Order API
    fileprivate func completeOrder() {
        
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
            ] as [AnyHashable: Any]
        
        Moltin.sharedInstance().cart.order(withParameters: orderParameters, success: { (response) -> Void in
            // Order succesful
            print("Order succeeded: \(response)")
            
            // Extract the Order ID so that it can be used in payment too...
            let orderId = NSDictionary(dictionary: response!).value(forKeyPath: "result.id") as! String
            print("Order ID: \(orderId)")

            let paymentParameters = ["data": ["number": self.cardNumber!,
                "expiry_month": self.selectedMonth!,
                "expiry_year":  self.selectedYear!,
                "cvv":          self.cvvNumber!
                ]] as [AnyHashable: Any]
            
            Moltin.sharedInstance().checkout.payment(withMethod: self.PAYMENT_METHOD, order: orderId, parameters: paymentParameters, success: { (response) -> Void in
                // Payment successful...
                print("Payment successful: \(response)")
            
                
                SwiftSpinner.hide()
                
                self.jumpToCartView(true)


                

                
                }) { (response, error) -> Void in
                    // Payment error
                    print("Payment error: \(error)")
                    SwiftSpinner.hide()
                    AlertDialog.showAlert("Payment Failed", message: "Payment failed - please try again", viewController: self)


            }
            
            
            }) { (response, error) -> Void in
                // Order failed
                print("Order error: \(error)")
                SwiftSpinner.hide()
                
                AlertDialog.showAlert("Order Failed", message: "Order failed - please try again", viewController: self)

        }
        
        
    }
    
    
}
