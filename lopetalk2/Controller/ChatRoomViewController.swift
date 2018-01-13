//
//  ChatRoomViewController.swift
//  lopetalk2
//
//  Created by marky RE on 11/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import UIKit
import LGButton
class ChatRoomViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var showMessageList:LGButton!
    var desuid:String?
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showMessageList.titleFontSize = 30
        tableView.tableFooterView = UIView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func showMsgList() {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "sendMessage") as! SendMessageViewController
        self.present(view, animated: true, completion: nil)
    }

}
extension ChatRoomViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as! SendTableViewCell
        cell.name.text = CurrentUser.username
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let sendMessageController = UIViewController.getStoryboardInstance("sendMessage") as! SendMessageViewController
        sendMessageController.user = CurrentUser.friendlist[indexPath.row]
        self.navigationController?.pushViewController(sendMessageController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}
