//
//  TextEntryTableViewCell.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 17/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

protocol TextEntryTableViewCellDelegate {
    func textEnteredInCell(cell: TextEntryTableViewCell, cellId:String, text: String)
}

class TextEntryTableViewCell: UITableViewCell {
    static let REUSE_IDENTIFIER = "textEntryCell"
    
    @IBOutlet weak var textField:UITextField?
    
    var cellId:String?
    
    var delegate:TextEntryTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
