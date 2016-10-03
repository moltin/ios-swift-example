//
//  SwitchTableViewCell.swift
//  MoltinSwiftExample
//
//  Created by Dylan McKee on 18/08/2015.
//  Copyright (c) 2015 Moltin. All rights reserved.
//

import UIKit

let SWITCH_TABLE_CELL_REUSE_IDENTIFIER = "switchCell"

protocol SwitchTableViewCellDelegate {
    func switchCellSwitched(_ cell: SwitchTableViewCell, status: Bool)
}

class SwitchTableViewCell: UITableViewCell {
    var delegate:SwitchTableViewCellDelegate?
    @IBOutlet weak var switchLabel:UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if (delegate != nil) {
            delegate!.switchCellSwitched(self, status: sender.isOn)
        }
    }

}
