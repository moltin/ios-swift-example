//
//  ProductsListTableViewCell.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 16/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

class ProductsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productNameLabel:UILabel?
    @IBOutlet weak var productPriceLabel:UILabel?
    @IBOutlet weak var productImageView:UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithProduct(productDict: NSDictionary) {
        // Setup the cell with information provided in productDict.
        productNameLabel?.text = productDict.valueForKey("title") as? String
        
        productPriceLabel?.text = productDict.valueForKeyPath("price.data.formatted.with_tax") as? String
        
        var imageUrl = ""
        
        if let images = productDict.objectForKey("images") as? NSArray {
            if (images.firstObject != nil) {
                imageUrl = images.firstObject?.valueForKeyPath("url.https") as! String
            }
            
        }

        productImageView?.sd_setImageWithURL(NSURL(string: imageUrl))
        
        
    }

}
