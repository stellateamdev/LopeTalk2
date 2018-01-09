//
//  BlockListTableViewCell.swift
//  lopetalk2
//
//  Created by marky RE on 18/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
protocol BlockListDelegate:class {
    func firstAction() -> Void
    func secondAction() -> Void
}
class BlockListTableViewCell: UITableViewCell {
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var edit:UIButton!
    weak var delegate:BlockListDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.height/2.0
        profileImage.clipsToBounds = true
        
        edit.setTitle("Edit", for: .normal)
        edit.addTarget(self, action: #selector(BlockListTableViewCell.showActionSheet), for: .touchUpInside)
        edit.setTitleColor(UIColor.darkGray, for: .normal)
        edit.layer.cornerRadius = 5.0
        edit.backgroundColor = UIColor.editGreyColor()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }


}
extension BlockListTableViewCell:ActionSheetDelegate{
    func thirdAction() {
        
    }
    
    func firstAction() {
        self.delegate?.firstAction()
    }
    
    func secondAction() {
        self.delegate?.secondAction()
    }
    @objc func showActionSheet() {
        let acsheetModel = ActionSheetModel()
        acsheetModel.delegate = self
        acsheetModel.firstBtnTitle = "Unblock"
        acsheetModel.secondBtnTitle = "Delete"
        let acsheet = acsheetModel.setUp(false)
        acsheet.show()
    }
    
    
}
