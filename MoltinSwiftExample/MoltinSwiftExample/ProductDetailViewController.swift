//
//  ProductDetailViewController.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 16/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import Moltin
import SwiftSpinner

class ProductDetailViewController: UIViewController {
    
    var productDict:NSDictionary?
    
    @IBOutlet weak var descriptionTextView:UITextView?
    @IBOutlet weak var productImageView:UIImageView?
    @IBOutlet weak var buyButton:UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let description = productDict!.valueForKey("description") as? String {
            self.descriptionTextView?.text = description

        }

        if let price = productDict!.valueForKeyPath("price.data.formatted.with_tax") as? String {
            let buyButtonTitle = String(format: "Buy Now (%@)", price)
            self.buyButton?.setTitle(buyButtonTitle, forState: UIControlState.Normal)
        }
        
        var imageUrl = ""
        
        if let images = productDict!.objectForKey("images") as? NSArray {
            if (images.firstObject != nil) {
                imageUrl = images.firstObject?.valueForKeyPath("url.https") as! String
            }
            
        }
        
        productImageView?.sd_setImageWithURL(NSURL(string: imageUrl))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buyProduct(sender: AnyObject) {
        // Add the current product to the cart
    }
    


}
