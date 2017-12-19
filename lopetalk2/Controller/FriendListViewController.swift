//
//  ViewController.swift
//  lopetalk2
//
//  Created by marky RE on 16/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import Hokusai
import PMAlertController
class FriendListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(FriendListViewController.edit))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FriendListViewController.showActionSheet))
        let nav = self.navigationController as! NavigationViewController
        nav.titleLabel.text = "LopeTalk"
        nav.titleLabel.font = UIFont.systemFont(ofSize: 38, weight: UIFont.Weight.heavy)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as! FriendListTableViewCell
        cell.name.text = "Dorajuneyaki"
        cell.detailTextLabel?.text = "yo"
        
        cell.profileImage.image = UIImage(named:"obama")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        self.pushView(self,"sendMessage")
        self.tabBarController?.tabBar.isHidden = true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let block = UITableViewRowAction(style: .normal, title: "Block") { action, index in
            let alert = UIAlertController(title: "Are you sure?", message: "You will not be able to send and receivee message from this user until you unblock them.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive, handler: {_ in
                
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        block.backgroundColor = .red
        
        return [block]
    }
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
extension FriendListViewController {
    
    @objc func showActionSheet(){
        let acsheetModel = ActionSheetModel()
        acsheetModel.delegate = self
        acsheetModel.firstBtnTitle = "Add Friend"
        acsheetModel.secondBtnTitle = "Add Message"
        let acsheet = acsheetModel.setUp()
        acsheet.show()
    }
    @objc func edit() {
        if self.navigationItem.leftBarButtonItem?.title == "Edit" {
        self.tableView.setEditing(true, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Done"
        }
        else{
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        }
    }
}
extension FriendListViewController:ActionSheetDelegate {
    func firstAction() {
        let alertVC = PMAlertController(title: "Add new friend", description: "Add new friend now \nso you and your friend can communicate!", image: UIImage(named:"addFriend"), style: .alert)
        alertVC.dismissWithBackgroudTouch = true
        alertVC.alertImage.tintColor = UIColor.lopeColor()
        alertVC.addTextField { (textField) in
            textField?.placeholder = "Type friend's username here.."
        }
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
            print("Capture action Cancel")
        }))
        alertVC.addAction(PMAlertAction(title: "Add", style: .default, action: { () -> Void in
            alertVC.dismiss(animated: true, completion: nil)
            let passVC = PMAlertController(title: "Success!", description: "Successfully added.\nEnjoy a simple conversation with your friend!", image: UIImage(named:"checkmark"), style: .alert)
            passVC.dismissWithBackgroudTouch = true
            passVC.alertImage.tintColor = UIColor.checkmarkGreen()
            passVC.dismissWithBackgroudTouch = true
            passVC.addAction(PMAlertAction(title: "Great!", style: .default , action: { () -> Void in
                passVC.dismiss(animated: true, completion: nil)
            }))
            self.present(passVC, animated: true, completion: nil)
        }))
        
        
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func secondAction() {
        let alertVC = PMAlertController(title: "Add message", description: "Add new message now \nso it's easier to communicate!", image: UIImage(named:"addMessage"), style: .alert)
        alertVC.dismissWithBackgroudTouch = true
       alertVC.alertImage.tintColor = UIColor.lopeColor()
        alertVC.addTextField { (textField) in
            textField?.placeholder = "Type message here.."
        }
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
            print("Capture action Cancel")
        }))
        alertVC.addAction(PMAlertAction(title: "Add", style: .default, action: { () -> Void in
            alertVC.dismiss(animated: true, completion: nil)
            let passVC = PMAlertController(title: "Success!", description: "Successfully added.\nEnjoy your time with LopeTalk!", image: UIImage(named:"checkmark"), style: .alert)
            passVC.dismissWithBackgroudTouch = true
            passVC.alertImage.tintColor = UIColor.checkmarkGreen()
            passVC.dismissWithBackgroudTouch = true
            passVC.addAction(PMAlertAction(title: "Great!", style: .default , action: { () -> Void in
                passVC.dismiss(animated: true, completion: nil)
            }))
            self.present(passVC, animated: true, completion: nil)
        }))
     
       
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
}

