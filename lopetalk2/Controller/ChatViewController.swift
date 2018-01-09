//
//  ChatViewController.swift
//  lopetalk2
//
//  Created by marky RE on 16/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import PMAlertController
import Firebase
import SCLAlertView

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ChatViewController.edit))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FriendListViewController.showActionSheet))
        let nav = self.navigationController as! NavigationViewController
        nav.titleLabel.text = "Messages"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        cell.name.text = "Dorajuneyaki"
        cell.message.text = "I Love You"
        cell.profileImage.image = UIImage(named:"obama")
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let block = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let alert = UIAlertController(title: "", message: "Are you sure you want to\ndelete this chat?", preferredStyle: .alert)
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
extension ChatViewController {

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
extension ChatViewController:ActionSheetDelegate {
    
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
            CurrentUser.addFriend(alertVC.textFields[0].text!, completion: {(finish) in
                let appearanceSuccess = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                    kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                    kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                    showCloseButton: false
                )
                let alertSuccess = SCLAlertView(appearance: appearanceSuccess)
                if finish {
                    alertSuccess.addButton("Done", action: {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            alertSuccess.dismiss(animated: true, completion: nil)
                            alertVC.dismiss(animated: true, completion: nil)
                        }
                    })
                    let passVC = PMAlertController(title: "Success!", description: "Successfully added.\nEnjoy a simple conversation with your friend!", image: UIImage(named:"checkmark"), style: .alert)
                    passVC.dismissWithBackgroudTouch = true
                    passVC.alertImage.tintColor = UIColor.checkmarkGreen()
                    passVC.dismissWithBackgroudTouch = true
                    passVC.addAction(PMAlertAction(title: "Great!", style: .default , action: { () -> Void in
                        passVC.dismiss(animated: true, completion: nil)
                    }))
                    self.present(passVC, animated: true, completion: nil)
                }
                else{
                    alertSuccess.addButton("Done", action: {
                        alertSuccess.dismiss(animated: true, completion: nil)
                    })
                    alertSuccess.showError("Error", subTitle: "There's no user with this username")
                }
                
            })
            
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
            if alertVC.textFields[0].text == "" {
                let appearanceSuccess = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                    kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                    kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                    showCloseButton: false
                )
                let alertSuccess = SCLAlertView(appearance: appearanceSuccess)
                alertSuccess.addButton("Done", action: {
                    alertSuccess.dismiss(animated: true, completion: nil)
                })
                alertSuccess.showError("Error", subTitle: "Please enter the message you want to save")
            }
            else{
                CurrentUser.addMessage(alertVC.textFields[0].text!, completion: {(success) in
                    if !success {
                        let appearanceSuccess = SCLAlertView.SCLAppearance(
                            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                            kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                            kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                            showCloseButton: false
                        )
                        let alertSuccess = SCLAlertView(appearance: appearanceSuccess)
                        alertSuccess.addButton("Done", action: {
                            alertSuccess.dismiss(animated: true, completion: nil)
                        })
                        
                        alertSuccess.showError("Error", subTitle: "Cannot add message, please try again")
                    }
                    else{
                        alertVC.dismiss(animated: true, completion: nil)
                        let passVC = PMAlertController(title: "Success!", description: "Successfully added.\nEnjoy your time with LopeTalk!", image: UIImage(named:"checkmark"), style: .alert)
                        passVC.dismissWithBackgroudTouch = true
                        passVC.alertImage.tintColor = UIColor.checkmarkGreen()
                        passVC.dismissWithBackgroudTouch = true
                        passVC.addAction(PMAlertAction(title: "Great!", style: .default , action: { () -> Void in
                            passVC.dismiss(animated: true, completion: nil)
                        }))
                        self.present(passVC, animated: true, completion: nil)
                    }
                })
            }
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
}
