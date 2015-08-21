//
//  String+Numeric.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 21/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import Foundation

extension String {
    func isNumericString() -> Bool {
        
        let nonDigitChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        
        let string = self as NSString
        
        if string.rangeOfCharacterFromSet(nonDigitChars).location == NSNotFound {
            // definitely numeric entierly
            return true
        }
        
        return false
    }
}