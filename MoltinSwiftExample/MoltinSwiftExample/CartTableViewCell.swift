//
//  CartTableViewCell.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 16/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

protocol CartTableViewCellDelegate {
    func cartTableViewCellSetQuantity(_ cell: CartTableViewCell, quantity: Int)
}

class CartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView:UIImageView?
    @IBOutlet weak var itemTitleLabel:UILabel?
    @IBOutlet weak var itemPriceLabel:UILabel?
    @IBOutlet weak var itemQuantityLabel:UILabel?
    @IBOutlet weak var itemQuantityStepper:UIStepper?
    
    var delegate:CartTableViewCellDelegate?
    
    var productId:String?

    var quantity:Int {
        get {
            if (self.itemQuantityStepper != nil) {
                return Int(self.itemQuantityStepper!.value)
            }
            
            return 0
        }
        
        set {
            self.setItemQuantity(quantity)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItemDictionary(_ itemDict: NSDictionary) {
        
        itemTitleLabel?.text = itemDict.value(forKey: "title") as? String
        
        itemPriceLabel?.text = itemDict.value(forKeyPath: "totals.post_discount.formatted.with_tax") as? String
        
        if let qty:NSNumber = itemDict.value(forKeyPath: "quantity") as? NSNumber {
            _ = "Qty. \(qty.intValue)"
            self.itemQuantityStepper?.value = qty.doubleValue
        }
        

        
        var imageUrl = ""
        
        if let images = itemDict.object(forKey: "images") as? NSArray {
            if (images.firstObject != nil) {
                imageUrl = (images.firstObject as! NSDictionary).value(forKeyPath: "url.https") as! String
            }
            
        }
        
        itemImageView?.sd_setImage(with: URL(string: imageUrl))
    }
    
    @IBAction func stepperValueChanged(_ sender: AnyObject){
        let value = Int(itemQuantityStepper!.value)
        
        setItemQuantity(value)
        
    }
    
    func setItemQuantity(_ quantity: Int) {
        let itemQuantityText = "Qty. \(quantity)"
        itemQuantityLabel?.text = itemQuantityText
        
        itemQuantityStepper?.value = Double(quantity)
        
        // Notify delegate, if there is one, too...
        if (delegate != nil) {
            delegate?.cartTableViewCellSetQuantity(self, quantity: quantity)
        }
        
    }

}
