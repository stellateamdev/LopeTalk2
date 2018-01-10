//
//  FriendRequestViewController.swift
//  lopetalk2
//
//  Created by marky RE on 9/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import SCLAlertView

class FriendRequestViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var headerView:UIView!
    private let refreshControl = UIRefreshControl()
    
    var selectedRow = 0
    override func viewWillAppear(_ animated: Bool) {

            self.tabBarController?.tabBar.isHidden = true

    }
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
        refreshTableView()
        
        let nav = self.navigationController as! NavigationViewController
        nav.titleLabel.text = "Friend Request"
        nav.titleLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.heavy)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        let nav = self.navigationController as! NavigationViewController
        nav.titleLabel.text = "LopeTalk"
        self.tabBarController?.tabBar.isHidden = false
        
        
    }

}
extension FriendRequestViewController: UITableViewDataSource,UITableViewDelegate,FriendRequestDelegate {
    func accept() {
        CurrentUser.acceptRequest(CurrentUser.requestlist[selectedRow]["uid"] as! String, completion: {(success) in
            if success{
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
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
                alert.showError("Error", subTitle: "Cannot add friend, please try again")
            }
        })
    }
    
    @objc func refreshTableView() {
        CurrentUser.getRequestList(completion: {(success) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestListCell", for: indexPath) as! FriendRequestTableViewCell
        guard let user = CurrentUser.requestlist[indexPath.row] as? [String:Any] else { return cell }
        guard let username = user["displayName"] as? String else { return cell }
        guard let imageURL = user["profilePicture"] as? String else { return cell }
        cell.delegate = self
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
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let block = UITableViewRowAction(style: .normal, title: "Block") { action, index in
            CurrentUser.blockRequest(CurrentUser.requestlist[index.row]["uid"] as! String, completion: {(success) in
                if success {
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
        }
        block.backgroundColor = .red
        
        return [block]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        selectedRow = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentUser.requestlist.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

