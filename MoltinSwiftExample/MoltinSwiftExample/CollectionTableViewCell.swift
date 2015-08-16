//
//  CollectionTableViewCell.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 15/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit
import SDWebImage

class CollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionLabel:UILabel?
    @IBOutlet weak var collectionImage:UIImageView?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionDictionary(dict: NSDictionary) {
        // Set up the cell based on the values of the dictionary that we've been passed
        
        collectionLabel?.text = dict.valueForKey("title") as? String
    
        // Extract image URL and set that too...
        var imageUrl = ""
        
        if let images = dict.valueForKey("images") as? NSArray {
            if (images.firstObject != nil) {
                imageUrl = images.firstObject?.valueForKeyPath("url.https") as! String
            }
        }
        
        collectionImage?.sd_setImageWithURL(NSURL(string: imageUrl))
        
        
    }

}
