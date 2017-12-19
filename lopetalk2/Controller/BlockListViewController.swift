//
//  BlockListViewController.swift
//  lopetalk2
//
//  Created by marky RE on 18/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit

class BlockListViewController: UIViewController {
    @IBOutlet weak var headerView:UIView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var textView:UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.backgroundColor = UIColor.tableViewBackgroundColor()
        
        textView.text = "You won't receive any messages from users who you block or delete from your \"Block List\" list.To send messages to users who you deleted from this list, you can add them again using their username."
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
        textView.textColor = UIColor.darkGray
        textView.backgroundColor = UIColor.tableViewBackgroundColor()
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockListCell", for: indexPath) as! BlockListTableViewCell
        cell.name.text = "Dorajuneyaki"
        cell.profileImage.image = UIImage(named:"obama")
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
extension BlockListViewController:BlockListDelegate{
    func firstAction() {
        
    }
    
    func secondAction() {
        
    }
    
    
}
