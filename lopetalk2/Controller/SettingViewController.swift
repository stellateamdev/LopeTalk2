//
//  SettingViewController.swift
//  lopetalk2
//
//  Created by marky RE on 16/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import SCLAlertView
class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView:HeaderView!
    
    var viewModel = SettingViewModel()
    var indicator = UIActivityIndicatorView()
    var indexPath:IndexPath!
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController as! NavigationViewController
        nav.showBigTitle()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.tableViewBackgroundColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

 
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingTableViewCell
         cell.textLabel?.text = viewModel.settings[indexPath.section][indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as! SettingTableViewCell
        self.indexPath = indexPath
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.pushView("profile")
                self.tabBarController?.tabBar.isHidden = true
            }
            else{
              self.showActionSheet(CurrentUser.email,"Change password")
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.showActionSheet("SMS","Email")
            }
            else {
                self.pushView("blockList")
                self.tabBarController?.tabBar.isHidden = true
            }
        }
        else if indexPath.section == 2{
            if indexPath.row == 0 {
                
            }
            else if indexPath.row == 1 {
                
            }
            else if indexPath.row == 2 {
                
            }
            else {
                sendEmail(cell)
            }
        }
        else{
            confirmLogOut()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settings[section].count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settings.count
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        let nav = self.navigationController as! NavigationViewController
        nav.removeBigTitle()
    }
    func confirmLogOut() {
        let alert = UIAlertController(title: "Are you sure you want to logout?", message: "", preferredStyle: .alert)
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
            kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
            kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
            showCloseButton: true
        )
        let errorAlert = SCLAlertView(appearance: appearance)
        let action = UIAlertAction(title: "Logout", style: .destructive, handler: {_ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                let view = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
                self.present(view, animated: true, completion: {
                    CurrentUser.removeUser()
                })
            } catch let signOutError as NSError {
                errorAlert.showError("Error", subTitle: "Error signing out, please try again.")
                print ("Error signing out: %@", signOutError)
            }
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

}

extension SettingViewController:MFMailComposeViewControllerDelegate{
    func sendEmail(_ cell:SettingTableViewCell) {
        indicator = ActivityIndicator.showActivityIndicatory()
        cell.accessoryView = indicator
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["stellateamdev@gmail.com"])
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: {
            cell.accessoryView = cell.addArrow()
        })
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion:{})
    }
}
extension SettingViewController:MFMessageComposeViewControllerDelegate {
    func sendSMSText() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Yo dude. Download this app and add me ASAP!/nMy username is \(CurrentUser.username)"
            controller.recipients = []
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension SettingViewController:ActionSheetDelegate{
    func thirdAction() {}
    
    func firstAction() {
        if indexPath.section == 0 && indexPath.row == 1 {
            
        }
        else{
            sendSMSText()
        }
    }
    
    func secondAction() {
        if indexPath.section == 0 && indexPath.row == 1 {
            CurrentUser.resetPassword()
        }
        else{
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([])
            composeVC.setMessageBody("Yo dude. Download this app and add me ASAP!/nMy username is \(CurrentUser.username)", isHTML: false)
            self.present(composeVC, animated: true, completion:nil)
        }
        }
    func showActionSheet(_ first:String,_ second:String) {
        let acsheetModel = ActionSheetModel()
        acsheetModel.delegate = self
        acsheetModel.firstBtnTitle = first
        acsheetModel.secondBtnTitle = second
        let acsheet = acsheetModel.setUp(false)
        acsheet.show()
    }
    }

