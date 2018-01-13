//
//  SendTableViewCell.swift
//  lopetalk2
//
//  Created by marky RE on 11/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import UIKit

class SendTableViewCell: UITableViewCell {
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var message:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        message.lineBreakMode = .byWordWrapping
        message.numberOfLines = 0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
