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
import Alamofire
import AlamofireImage
import Lightbox
import MapKit
import JGProgressHUD
class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var openmap = false
    private var lat:Double = 0.0
    private var long:Double = 0.0
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        refreshControl.addTarget(self, action: #selector(ChatViewController.refreshTableView), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ChatViewController.edit))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FriendListViewController.showActionSheet))
        let nav = self.navigationController as! NavigationViewController
        nav.titleLabel.text = "Notifications"
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.refreshTableView()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func refreshTableView() {
        CurrentUser.getNotiList(completion: {(success) in
            if success {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
                
            }
            else{
                print("fucked up")
                self.refreshControl.endRefreshing()
            }
        })
    }
}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        cell.name.text = CurrentUser.notilist[indexPath.row]["username"] as! String
        cell.message.text = CurrentUser.notilist[indexPath.row]["message"] as! String
        let imageURL = CurrentUser.notilist[indexPath.row]["profilePicture"] as! String
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
        return CurrentUser.notilist.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
       if CurrentUser.notilist[indexPath.row]["picture"] as! String != "" {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Downloading.."
        hud.show(in: self.view)
        let imageURL = CurrentUser.notilist[indexPath.row]["picture"] as! String
        Alamofire.request(imageURL).responseImage { response in
            debugPrint(response)
            if let image = response.result.value {
                hud.dismiss()
                print("image is received 3425")
                self.showLightbox(image)
            }
        }
        }
       else if CurrentUser.notilist[indexPath.row]["lat"] as! String != "" && CurrentUser.notilist[indexPath.row]["long"] as! String != "" {
        lat = Double(CurrentUser.notilist[indexPath.row]["lat"] as! String)!
        long = Double(CurrentUser.notilist[indexPath.row]["long"] as! String)!
            openmap = true
            showActionSheet()
       }
        else {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "sendMessage") as! SendMessageViewController
            view.user = CurrentUser.notilist[indexPath.row]
        self.present(view, animated: true, completion: nil)
        }
        
    }
}
extension ChatViewController {

    @objc func showActionSheet(){
        let acsheetModel = ActionSheetModel()
        acsheetModel.delegate = self
        if openmap {
            acsheetModel.firstBtnTitle = "Open in Google maps"
            acsheetModel.secondBtnTitle = "Open in Apple maps"
             let acsheet = acsheetModel.setUp(false)
            acsheet.show()
        }
        else{
            acsheetModel.firstBtnTitle = "Add Friend"
            acsheetModel.secondBtnTitle = "Add Message"
            acsheetModel.thirdBtnTitle = "Friend Request"
             let acsheet = acsheetModel.setUp(true)
            acsheet.show()
        }

       
        
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
        if !openmap {
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
        else{
            openmap = false
            let googleMapsInstalled = UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)
            if googleMapsInstalled {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "comgooglemaps-x-callback://" +
                        "?daddr=\(lat),\(long)&directionsmode=bicycling&zoom=17")!)
                } else {
                    // Fallback on earlier versions
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
                lat = 0.0
                long = 0.0
                alert.showError("Error", subTitle: "Google maps is not installed in your device, Please try again")
            }
        }
    }
    
    func secondAction() {
        if !openmap {
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
        else{
            openmap = false
            let coordinates = CLLocationCoordinate2DMake(lat, long)
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.openInMaps(launchOptions: nil)
            lat = 0.0
            long = 0.0
        }
    }
    func thirdAction() {
        self.pushView("friendRequest")
    }
    func showLightbox(_ image:UIImage) {
        let images = [
            LightboxImage(
                image: image,
                text: ""
            )
        ]
        
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        
        present(controller, animated: true, completion: nil)
    }
    
    
}

