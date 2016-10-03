//
//  ShippingMethodTableViewCell.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 17/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

class ShippingMethodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var methodNameLabel:UILabel?
    @IBOutlet weak var costLabel:UILabel?


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
