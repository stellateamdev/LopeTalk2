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
import Firebase
import SCLAlertView
import Alamofire
import AlamofireImage

class FriendListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(FriendListViewController.refreshTableView), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(FriendListViewController.edit))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FriendListViewController.showActionSheet))
        let nav = self.navigationController as! NavigationViewController
        nav.titleLabel.text = "LopeTalk"
        nav.titleLabel.font = UIFont.systemFont(ofSize: 38, weight: UIFont.Weight.heavy)
   
    }
    override func viewWillAppear(_ animated: Bool) {
        self.refreshTableView()
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
extension FriendListViewController:UITableViewDelegate,UITableViewDataSource {
    @objc func refreshTableView() {
        CurrentUser.getFriendlist(completion: {(success) in
            DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            }
        })
    }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as! FriendListTableViewCell
            guard let user = CurrentUser.friendlist[indexPath.row] as? [String:Any] else { return cell }
            guard let username = user["displayName"] as? String else { return cell }
            guard let imageURL = user["profilePicture"] as? String else { return cell }
            cell.name.text = username
            Alamofire.request(imageURL).responseImage { response in
                debugPrint(response)
                print(imageURL)
                if let image = response.result.value {
                    let aspectScaledToFitImage = image.af_imageAspectScaled(toFit: cell.profileImage.frame.size)
                    cell.profileImage.image = aspectScaledToFitImage
                    print("image downloaded: \(image)")
                }
            }
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.tableView.deselectRow(at: indexPath, animated: false)
            self.pushView(self,"sendMessage")
            self.tabBarController?.tabBar.isHidden = true
        }
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return CurrentUser.friendlist.count
        }
    
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    
        func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
            let block = UITableViewRowAction(style: .normal, title: "Block") { action, index in
                let alert = UIAlertController(title: "Are you sure?", message: "You will not be able to send and receive message from this user until you unblock them.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .destructive, handler: { _ in
                    print("enter block")
                    CurrentUser.blockUser(CurrentUser.friendlist[index.row]["uid"] as! String, completion: {(success) in
                        if success {
//                            CurrentUser.friendlist.remove(at: CurrentUser.friendlist.index(where: {$0["uid"] as! String == CurrentUser.friendlist[index.row]["uid"] as! String})!)
                            DispatchQueue.main.async {
                            self.tableView.reloadData()
                            }
                        }
                        else{
                            let appearance = SCLAlertView.SCLAppearance(
                                kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                                kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                                kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                                showCloseButton: true
                            )
                            let alert = SCLAlertView(appearance: appearance)
                            alert.showError("Error", subTitle: "cannot block user, please try again")
                        }
                    })
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
                        self.tableView.reloadData()
                        alertSuccess.dismiss(animated: true, completion: nil)
                        alertVC.dismiss(animated: true, completion: nil)
                    })
                    let passVC = PMAlertController(title: "Success!", description: "Successfully added.\nEnjoy a simple conversation with your friend!", image: UIImage(named:"checkmark"), style: .alert)
                    passVC.dismissWithBackgroudTouch = true
                    passVC.alertImage.tintColor = UIColor.checkmarkGreen()
                    passVC.dismissWithBackgroudTouch = true
                    passVC.addAction(PMAlertAction(title: "Great!", style: .default , action: { () -> Void in
                        self.refreshControl.beginRefreshing()
                        CurrentUser.getFriendlist(completion: {(success) in
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.refreshControl.endRefreshing()
                                passVC.dismiss(animated: true, completion: nil)
                            }
                        })
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

