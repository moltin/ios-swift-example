//
//  AlertDialog.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 18/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import Foundation
import UIKit

// A simple convenience class to present alerts, to avoid lots of UIAlertController code duplication.
class AlertDialog {
    
    class func showAlert(_ title: String, message: String, viewController: UIViewController) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        
        viewController.present(alertController, animated: true, completion: nil)
        
    }
    
}
