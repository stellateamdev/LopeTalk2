//
//  SettingTableViewCell.swift
//  lopetalk2
//
//  Created by marky RE on 17/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
   
    override func awakeFromNib() {
        super.awakeFromNib()
        let image = UIImage(named: "arrow")
        let arrow = UIImageView(frame:CGRect(x:0, y:0, width:20, height:20));
        arrow.image = image
        self.accessoryView = arrow
        self.textLabel?.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        // Initialization code
    }
    func addArrow() -> UIImageView{
        let image = UIImage(named: "arrow")
        let arrow = UIImageView(frame:CGRect(x:0, y:0, width:20, height:20));
        arrow.image = image
        return arrow
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
