//
//  ChatTableViewCell.swift
//  lopetalk2
//
//  Created by marky RE on 17/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var message:UILabel!
    @IBOutlet weak var profileImage:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
//        let image = UIImage(named: "arrow")
//        let checkmark  = UIImageView(frame:CGRect(x:0, y:0, width:20, height:20));
//        checkmark.image = image
//        self.accessoryView = checkmark

        name.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.bold)
        message.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        message.textColor = UIColor.darkGray
        profileImage.layer.cornerRadius = profileImage.frame.height/2.0
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
          profileImage.image = UIImage(named:"profileLoad")
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
