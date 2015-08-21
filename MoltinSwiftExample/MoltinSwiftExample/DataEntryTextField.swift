//
//  DateEntryTextField.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 21/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

class DataEntryTextField: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    func setDoneInputAccessoryView() {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.frame.size.width, 44))
        
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "btnDoneTap:")

        
        toolbar.setItems([space, doneButton], animated: true)
        
        self.inputAccessoryView = toolbar
        
    }
    
    func btnDoneTap(sender: AnyObject) {
        resignFirstResponder()
    }

}
