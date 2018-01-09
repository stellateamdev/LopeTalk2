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
class FriendRequestViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var headerView:UIView!
    private let refreshControl = UIRefreshControl()
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
        
    }
    
    @objc func refreshTableView() {
        CurrentUser.getFriendlist(completion: {(success) in
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentUser.requestlist.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
