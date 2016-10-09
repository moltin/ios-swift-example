//
//  AddressEntryTableViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 17/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin

class AddressEntryTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, SwitchTableViewCellDelegate, TextEntryTableViewCellDelegate {
    
    var emailAddress:String?
    var billingDictionary:Dictionary<String, String>?
    var shippingDictionary:Dictionary<String, String>?
    
    var contactFieldsArray = Array<Dictionary< String, String>>()
    
    // Assume it's the billing contact address by default, unless told that it's the shipping address.
    var isShippingAddress = false
    
    var countryArray:Array<Dictionary< String, String>>?
    
    fileprivate var useSameShippingAddress = false
    
    fileprivate var selectedCountryIndex:Int?
    
    // Field identifier key constants
    fileprivate let contactEmailFieldIdentifier = "email"
    fileprivate let contactFirstNameFieldIdentifier = "first_name"
    fileprivate let contactLastNameFieldIdentifier = "last_name"
    fileprivate let address1FieldIdentifier = "address_1"
    fileprivate let address2FieldIdentifier = "address_2"
    fileprivate let cityFieldIdentifier = "city"
    fileprivate let stateFieldIdentifier = "state"
    fileprivate let countryFieldIdentifier = "country"
    fileprivate let postcodeFieldIdentifier = "postcode"
    
    fileprivate let countryPickerView = UIPickerView()
    
    fileprivate let BILLING_ADDRESS_SHIPPING_SEGUE = "billingShippingSegue"
    fileprivate let SHIPPING_ADDRESS_SHIPPING_SEGUE = "shippingShippingSegue"
    fileprivate let SHIPPING_ADDRESS_SEGUE = "shippingAddressSegue"

    
    //MARK: - View loading
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
            var userPresentableName = field.replacingOccurrences(of: "_", with: " ")
            userPresentableName = userPresentableName.capitalized
            
            var fieldDict = Dictionary<String, String>()
            fieldDict["name"] = userPresentableName
            fieldDict["identifier"] = field
            
            contactFieldsArray.append(fieldDict)
            
        }
        
        // If country array is blank, let's fetch it...
        if (countryArray == nil) {
            SwiftSpinner.show("Loading countries")
            
            // Fetch countries from Moltin API, showing loading animation whilst this async fetch is happening.
            Moltin.sharedInstance().address.fields(withCustomerId: "", andAddressId: "", success: { (response) -> Void in
                // Got a response, let's extract the countries...
                let responseDict = NSDictionary(dictionary: response!)
                let tmpCountries = responseDict.value(forKeyPath: "result.country.available") as! NSDictionary
                
                self.countryArray = Array<Dictionary< String, String>>()
                
                // Country codes are stored as keys, their values contain dicts, which in turn contain the country names.
                for countryCode in tmpCountries.allKeys {
                    var newCountry = Dictionary<String, String>()
                    if let codeString = countryCode as? String {
                        newCountry["code"] = codeString
                        newCountry["name"] = (tmpCountries.value(forKey: codeString) as! String)
                    }
                    self.countryArray?.append(newCountry)
                }
                

                // and hide loading UI.
                SwiftSpinner.hide()

                
                }, failure: { (response, error) -> Void in
                    // Something went wrong, alert user.
                    SwiftSpinner.hide()

                    AlertDialog.showAlert("Error", message: "Sorry, could not load countries", viewController: self)
                    print("Something went wrong...")
                    print(error)
            })
        }
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        countryPickerView.backgroundColor = UIColor.white
        countryPickerView.isOpaque = true

        // Load table data
        self.tableView.reloadData()
        
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if !isShippingAddress {
            return (contactFieldsArray.count + 2)
        }
        
        return (contactFieldsArray.count + 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (((indexPath as NSIndexPath).row == contactFieldsArray.count && isShippingAddress) || ((indexPath as NSIndexPath).row == contactFieldsArray.count + 1 && !isShippingAddress)) {
            // Show Continue button cell!
            let cell = tableView.dequeueReusableCell(withIdentifier: CONTINUE_BUTTON_CELL_IDENTIFIER, for: indexPath) as! ContinueButtonTableViewCell
            return cell

        }
        
        if ((indexPath as NSIndexPath).row == contactFieldsArray.count && !isShippingAddress) {
            // Show Switch cell
            let cell = tableView.dequeueReusableCell(withIdentifier: SWITCH_TABLE_CELL_REUSE_IDENTIFIER, for: indexPath) as! SwitchTableViewCell
            cell.switchLabel?.text = "Shipping address same as billing?"
            cell.switchLabel?.tintColor = MOLTIN_COLOR
            cell.delegate = self
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TEXT_ENTRY_CELL_REUSE_IDENTIFIER, for: indexPath) as! TextEntryTableViewCell
        
        // Configure the cell...
        cell.textField?.placeholder = contactFieldsArray[(indexPath as NSIndexPath).row]["name"]!
        let identifier = contactFieldsArray[(indexPath as NSIndexPath).row]["identifier"]!
        cell.cellId = identifier
        cell.delegate = self
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        if identifier == countryFieldIdentifier {
            // Make the country field non-editable, and attach the country picker view to it.
            cell.textField?.inputView = countryPickerView
            cell.textField?.setDoneInputAccessoryView()
            cell.hideCursor()
        }
        
        var dict = billingDictionary
        if isShippingAddress {
            dict = shippingDictionary
        }
        
        if let existingEntry = dict![identifier] {
            if existingEntry.characters.count > 0 {
                cell.textField?.text = existingEntry
            }
        }

        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // If the user tapped on the Continue button, continue!
        if (((indexPath as NSIndexPath).row == contactFieldsArray.count && isShippingAddress) || ((indexPath as NSIndexPath).row == contactFieldsArray.count + 1 && !isShippingAddress)) {
            continueButtonTapped()
            return
        }

    }
    
    //MARK: - Country picker delegate and data source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        
        return countryArray!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return countryArray![row]["name"]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // User's set a country.
        selectedCountryIndex = row
        
        if countryArray == nil {
            return
        }
        
        let selectedCountry = countryArray![row]["name"]!
        
        if isShippingAddress {
            shippingDictionary![countryFieldIdentifier] = selectedCountry
        } else {
            billingDictionary![countryFieldIdentifier] = selectedCountry
        }
        
        self.tableView.reloadData()
        
    }
    
    // MARK: - Data validation
    func validateData() -> Bool {
        var sourceDict:Dictionary<String, String>
        if !isShippingAddress {
            // Check email address too...
            if emailAddress == nil {
                // no email - warn and give up!
                AlertDialog.showAlert("Error", message: "No email address entered! Please enter a valid email and try again.", viewController: self)
                
                return false
            }
            
            sourceDict = billingDictionary!
        } else {
            sourceDict = shippingDictionary!
        }
        
        let requiredFields = [contactFirstNameFieldIdentifier, contactLastNameFieldIdentifier, address1FieldIdentifier, cityFieldIdentifier, stateFieldIdentifier, countryFieldIdentifier, postcodeFieldIdentifier]
        
        var valid = true
        
        for field in requiredFields {
            var valuePresent = false
            var lengthValid = false
            
            if let value = sourceDict[field] {
                // success
                valuePresent = true
                let stringValue = value as String
                if stringValue.characters.count < 1 {
                    // The string's empty!
                    lengthValid = true
                }
                continue
            } else {
                valuePresent = false
            }
            
            if !valuePresent || !lengthValid {
                // Warn user!
                valid = false
                
                var userPresentableName = field.replacingOccurrences(of: "_", with: " ")
                userPresentableName = userPresentableName.capitalized
                
                AlertDialog.showAlert("Error", message: "\(userPresentableName) is not present", viewController: self)
            }
        }
        
        return valid
        
    }
    
    // MARK: - Data processing

    // A function that gets all of the address field values and returns a billing or shipping address dictionary suitable to pass to the Moltin API.
    func getAddressDict() -> Dictionary<String, String> {
        var sourceDict:Dictionary<String, String>
        if !isShippingAddress {
            sourceDict = billingDictionary!
        } else {
            sourceDict = shippingDictionary!
        }
        
        var country = sourceDict[countryFieldIdentifier]
        // Perform a country code lookup
        if countryArray != nil {
            country = countryArray![selectedCountryIndex!]["code"]
            
        }
        
        var formattedDict = Dictionary<String, String>()
        formattedDict[contactFirstNameFieldIdentifier] = sourceDict[contactFirstNameFieldIdentifier]
        formattedDict[contactLastNameFieldIdentifier] = sourceDict[contactLastNameFieldIdentifier]
        formattedDict[address1FieldIdentifier] = sourceDict[address1FieldIdentifier]
        
        // Concatenate together Address 2...
        var address2 = ""
        if (formattedDict[address2FieldIdentifier] != nil) {
            // There's a value in address 2
            address2 = formattedDict[address2FieldIdentifier]!

        }
        
        // Add on city
        address2 = address2 +  ", " + sourceDict[cityFieldIdentifier]!
            
        // Add on state
        address2 = address2 + ", " +  sourceDict[stateFieldIdentifier]!

        
        formattedDict[countryFieldIdentifier] = country
        formattedDict[postcodeFieldIdentifier] = sourceDict[postcodeFieldIdentifier]
        
        return formattedDict

    }
    
    //MARK: - Text field Cell Delegate
    func textEnteredInCell(_ cell: TextEntryTableViewCell, cellId:String, text: String) {
        let cellId = cell.cellId!
        
        if cellId == contactEmailFieldIdentifier {
            emailAddress = text
            return
        }
        
        if isShippingAddress {
            shippingDictionary?[cellId] = text
        } else {
            billingDictionary?[cellId] = text
        }
    }
    
    //MARK: - Switch Cell Delegate
    func switchCellSwitched(_ cell: SwitchTableViewCell, status: Bool) {
        // User has selected to use the same shipping address as billing address.
        useSameShippingAddress = status
        
    }
    
    //MARK: - Continue Button
    fileprivate func continueButtonTapped() {
        // If this is the billing address screen, see if the user wants to enter a seperate shipping address...
        // If they do, transition to the shipping address entry screen
        // If they don't - or this is the shipping address screen - carry on with the order...
        
        
        // First, check the data entered is valid - if it isn't don't bother.
        if !validateData() {
            return
        }

        if isShippingAddress {
            performSegue(withIdentifier: SHIPPING_ADDRESS_SHIPPING_SEGUE, sender: self)
        } else {
            if useSameShippingAddress {
                // They wanna use the current billing address as the shipping address too, so we need to segue to the shipping method choice view, since we know all details now.
                performSegue(withIdentifier: BILLING_ADDRESS_SHIPPING_SEGUE, sender: self)
            } else {
                performSegue(withIdentifier: SHIPPING_ADDRESS_SEGUE, sender: self)

            }
            
        }
        
        

    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        
        // (initialising these to blanks here to silence Swift's warnings in the segue preperation later on - it doesn't trust that these have been initialised when they in fact WILL have by the time that segue is ever used).
        var billingDict = Dictionary<String, String>()
        var shippingDict = Dictionary<String, String>()
        
        if isShippingAddress {
            billingDict = billingDictionary!
            shippingDict = getAddressDict()
        } else {
            billingDict = getAddressDict()
            

        }
        
        if useSameShippingAddress {
            shippingDict = billingDict
        }

        
        if segue.identifier == SHIPPING_ADDRESS_SHIPPING_SEGUE || segue.identifier == BILLING_ADDRESS_SHIPPING_SEGUE {
            // Set up the shipping address view's address variables...
            let newViewController = segue.destination as! ShippingTableViewController
            newViewController.billingDictionary = billingDict
            newViewController.shippingDictionary = shippingDict
            
            print("shippingDict = \(shippingDict)")
            
            newViewController.emailAddress = emailAddress!
        }
        
        if segue.identifier == SHIPPING_ADDRESS_SEGUE {
            // We're seguing to another AddressEntryTableViewController instance, let's let it know that it's for shipping address entry, and that it has a billing address already...
            let newViewController = segue.destination as! AddressEntryTableViewController
            newViewController.isShippingAddress = true
            newViewController.billingDictionary = billingDict
            newViewController.countryArray = countryArray!
            newViewController.emailAddress = emailAddress!
        }
        
    }
    
}
