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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCollectionDictionary(_ dict: NSDictionary) {
        // Set up the cell based on the values of the dictionary that we've been passed
        
        collectionLabel?.text = dict.value(forKey: "title") as? String
    
        // Extract image URL and set that too...
        var imageUrl = ""
        
        if let images = dict.value(forKey: "images") as? NSArray {
            if (images.firstObject != nil) {
                imageUrl = (images.firstObject as! NSDictionary).value(forKeyPath: "url.https") as! String
            }
        }
        
        collectionImage?.sd_setImage(with: URL(string: imageUrl))
        
        
    }

}
