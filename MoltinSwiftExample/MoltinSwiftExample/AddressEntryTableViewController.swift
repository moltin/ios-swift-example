//
//  AddressEntryTableViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 17/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin
import SwiftSpinner

class AddressEntryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var billingDictionary:Dictionary<String, String>?
    var shippingDictionary:Dictionary<String, String>?
    
    var contactFieldsArray = Array<Dictionary< String, String>>()
    
    // Assume it's the billing contact address by default, unless told that it's the shipping address.
    var isShippingAddress:Bool = false
    
    var countryArray:Array<Dictionary< String, String>>?
    
    // Field identifier key constants
    private let contactEmailFieldIdentifier = "email"
    private let contactFirstNameFieldIdentifier = "first_name"
    private let contactLastNameFieldIdentifier = "last_name"
    private let address1FieldIdentifier = "address_1"
    private let address2FieldIdentifier = "address_2"
    private let cityFieldIdentifier = "city"
    private let stateFieldIdentifier = "state"
    private let countryFieldIdentifier = "country"
    private let postcodeFieldIdentifier = "postcode"
    
    private let countryPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fields = [contactFirstNameFieldIdentifier, contactLastNameFieldIdentifier, address1FieldIdentifier, address2FieldIdentifier, cityFieldIdentifier, stateFieldIdentifier, countryFieldIdentifier, postcodeFieldIdentifier]
        
        if !isShippingAddress {
            // Set-up extra billing address fields...
            fields = [contactEmailFieldIdentifier, contactFirstNameFieldIdentifier, contactLastNameFieldIdentifier, address1FieldIdentifier, address2FieldIdentifier, cityFieldIdentifier, stateFieldIdentifier, countryFieldIdentifier, postcodeFieldIdentifier]

            billingDictionary = Dictionary<String, String>()
            
            self.title = "Billing Address"

        } else {
            shippingDictionary = Dictionary<String, String>()
            
            self.title = "Shipping Address"

        }
        
        for field in fields {
            var userPresentableName = field.stringByReplacingOccurrencesOfString("_", withString: " ")
            userPresentableName = userPresentableName.capitalizedString
            
            var fieldDict = Dictionary<String, String>()
            fieldDict["name"] = userPresentableName
            fieldDict["identifier"] = field
            
            contactFieldsArray.append(fieldDict)
            
        }
        
        // If country array is blank, let's fetch it...
        if (countryArray == nil) {
            println("countryArray is nil")
            SwiftSpinner.show("Loading countries")
            
            // Fetch countries from Moltin API, showing loading animation whilst this async fetch is happening.
            Moltin.sharedInstance().address.fieldsWithCustomerId("", andAddressId: "", success: { (response) -> Void in
                // Got a response, let's extract the countries...
                let responseDict = response as NSDictionary
                let tmpCountries = responseDict.valueForKeyPath("result.country.available") as! NSDictionary
                
                self.countryArray = Array<Dictionary< String, String>>()
                
                // Country codes are stored as keys, their values contain dicts, which in turn contain the country names.
                for countryCode in tmpCountries.allKeys {
                    var newCountry = Dictionary<String, String>()
                    if let codeString = countryCode as? String {
                        newCountry["code"] = codeString
                        newCountry["name"] = (tmpCountries.valueForKey(codeString) as! String)
                    }
                    self.countryArray?.append(newCountry)
                }
                
                // Sort alphabetically by country name
                self.countryArray? = self.countryArray!.sorted({ $0["name"] < $1["name"]})
                
                // and hide loading UI.
                SwiftSpinner.hide()

                
                }, failure: { (response, error) -> Void in
                    // Something went wrong, alert user.
                    SwiftSpinner.hide()

                    AlertDialog.showAlert("Error", message: "Sorry, could not load countries", viewController: self)
                    
            })
        }
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self

        // Load table data
        self.tableView.reloadData()
        
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
        
        return (contactFieldsArray.count + 1)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == contactFieldsArray.count {
            // Show Continue button cell!
            let cell = tableView.dequeueReusableCellWithIdentifier(CONTINUE_BUTTON_CELL_IDENTIFIER, forIndexPath: indexPath) as! ContinueButtonTableViewCell
            return cell

        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TextEntryTableViewCell.REUSE_IDENTIFIER, forIndexPath: indexPath) as! TextEntryTableViewCell
        
        // Configure the cell...
        cell.textField?.placeholder = contactFieldsArray[indexPath.row]["name"]!
        var identifier = contactFieldsArray[indexPath.row]["identifier"]!
        cell.cellId? = identifier
        
        if identifier == countryFieldIdentifier {
            // Make the country field non-editable, and attach the country picker view to it.
            cell.textField?.inputAccessoryView = countryPickerView
        }
        
        var dict = billingDictionary
        if isShippingAddress {
            dict = shippingDictionary
        }
        
        if let existingEntry = dict![identifier] {
            if count(existingEntry) > 0 {
                cell.textField?.text = existingEntry
            }
        }

        
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // If the user tapped on the Continue button, continue!
        if indexPath.row == contactFieldsArray.count {
            
            return
        }

    }
    
    //MARK: - Country picker delegate and data source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        
        return countryArray!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        return countryArray![row]["name"]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // User's set a country.
        if countryArray == nil {
            return
        }
        
        let selectedCountry = countryArray![row]["name"]!
        
        print(selectedCountry)
        
        if isShippingAddress {
            shippingDictionary?[countryFieldIdentifier] = selectedCountry
        } else {
            billingDictionary?[countryFieldIdentifier] = selectedCountry
        }
        
        self.tableView.reloadData()
        
    }
    
    // A function that gets all of the address field values and returns a billing or shipping address dictionary suitable to pass to the Moltin API.
    func getAddressDict() -> Dictionary<String, String> {
        // TODO: Implement
        return Dictionary<String, String>()
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
}
