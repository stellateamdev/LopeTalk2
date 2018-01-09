//
//  FriendRequestTableViewCell.swift
//  lopetalk2
//
//  Created by marky RE on 9/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import UIKit
protocol FriendRequestDelegate:class {
    func accept() -> Void
}
class FriendRequestTableViewCell: UITableViewCell {
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var edit:UIButton!
    weak var delegate:FriendRequestDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.height/2.0
        profileImage.clipsToBounds = true
        
        edit.setTitle("Accept", for: .normal)
        edit.addTarget(self, action: #selector(FriendRequestTableViewCell.accept), for: .touchUpInside)
        edit.setTitleColor(UIColor.white, for: .normal)
        edit.layer.cornerRadius = 5.0
        edit.backgroundColor = UIColor.lopeColor()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @objc func accept() {
        self.delegate?.accept()
    }
    
}

