//
//  FriendListTableViewCell.swift
//  lopetalk2
//
//  Created by marky RE on 17/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
class FriendListTableViewCell: UITableViewCell {
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var profileImage:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.height/2.0
        profileImage.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
