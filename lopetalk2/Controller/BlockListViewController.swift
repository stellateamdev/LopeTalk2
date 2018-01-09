//
//  BlockListViewController.swift
//  lopetalk2
//
//  Created by marky RE on 18/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
class BlockListViewController: UIViewController {
    @IBOutlet weak var headerView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var textView:UITextView!
    private let refreshControl = UIRefreshControl()
    var selectedRow = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(FriendListViewController.refreshTableView), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        
        headerView.backgroundColor = UIColor.tableViewBackgroundColor()
        
        textView.text = "You won't receive any messages from users who you block or delete from your \"Block List\" list.To send messages to users who you deleted from this list, you can add them again using their username."
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        textView.textColor = UIColor.darkGray
        textView.backgroundColor = UIColor.tableViewBackgroundColor()
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        refreshTableView()
        
        self.navigationItem.title = "Block List"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

}
extension BlockListViewController:UITableViewDataSource,UITableViewDelegate {
    
    @objc func refreshTableView() {
        CurrentUser.getBlockList(completion: {(success) in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockListCell", for: indexPath) as! BlockListTableViewCell
        cell.delegate = self
        guard let user = CurrentUser.blocklist[indexPath.row] as? [String:Any] else { return cell }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentUser.blocklist.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
    }
}
extension BlockListViewController:BlockListDelegate{
    func firstAction() {
        guard let uid = CurrentUser.blocklist[selectedRow]["uid"] as? String else{
            return
        }
        CurrentUser.unblockUser(uid, completion: {(success) in
            if success {
                DispatchQueue.main.async {
                self.tableView.reloadData()
                }
            }
            else{
                return
            }
        })
    }
    
    func secondAction() {
        guard let uid = CurrentUser.blocklist[selectedRow]["uid"] as? String else{
            return
        }
        CurrentUser.deleteUser(uid, completion: {(success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else{
                return
            }
        })
    }
    
    
}
