//
//  CartTableViewCell.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 16/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

protocol CartTableViewCellDelegate {
    func cartTableViewCellSetQuantity(cell: CartTableViewCell, quantity: Int)
}

class CartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView:UIImageView?
    @IBOutlet weak var itemTitleLabel:UILabel?
    @IBOutlet weak var itemQuantityLabel:UILabel?
    
    var delegate:CartTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItemDictionary(itemDict: NSDictionary) {
        
    }
    
    func setQuantity(quantity: Int) {
        let itemQuantityText = "Qty. \(quantity)"
        itemQuantityLabel?.text = itemQuantityText
        
    }

}
