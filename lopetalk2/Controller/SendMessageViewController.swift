//
//  SendMessageViewController.swift
//  lopetalk2
//
//  Created by marky RE on 19/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import LGButton
import Gallery
import SCLAlertView
import MapKit
import CoreLocation
import JGProgressHUD
import OneSignal

class SendMessageViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var headerView:UIView!
    @IBOutlet weak var location:LGButton!
    @IBOutlet weak var photo:LGButton!
    @IBOutlet weak var close:LGButton!
    
    var user:[String:Any]?
    var gallery:GalleryController!
    private let refreshControl = UIRefreshControl()
    private let locationManager = CLLocationManager()
    private var isLocate = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshTableView()
        headerView.backgroundColor = UIColor.lopeColor()
        if let nav = self.navigationController as? NavigationViewController {
            nav.titleLabel.text = "Send Message"
            nav.changeFontSize(30)
            close.isHidden = true
        }
        else{
            close.isHidden = false
            headerView.isHidden = true
            
        }
  
        self.tabBarController?.tabBar.isHidden = true
    }
//    override func viewDidAppear(_ animated: Bool) {
//        CurrentUser.getMessageList(completion: {(success) in
//            if success {
//                self.tableView.reloadData()
//            }
//        })
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        refreshControl.addTarget(self, action: #selector(SendMessageViewController.refreshTableView), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(SendMessageViewController.edit))
        
        location.isUserInteractionEnabled = true
        photo.isUserInteractionEnabled = true
        location.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SendMessageViewController.tapLocation)))
        photo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SendMessageViewController.showPhotoGallery)))
        
    
        

        // Do any additional setup after loading the view.
    }
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if let nav = self.navigationController as? NavigationViewController {
            nav.titleLabel.text = "LopeTalk"
            self.tabBarController?.tabBar.isHidden = false
        }
       
    }

    @objc func edit() {
        if self.navigationItem.rightBarButtonItem?.title == "Edit" {
            self.tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
        else{
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }

}
extension SendMessageViewController:UITableViewDataSource,UITableViewDelegate {
    @objc func refreshTableView() {
        CurrentUser.getMessageList(completion: {(success) in
            if success {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
         print("checkcheck \(CurrentUser.messages[indexPath.row])")
        guard let message = CurrentUser.messages[indexPath.row] as? String else { return cell }
        cell.textLabel?.text = message
        cell.textLabel?.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.medium)
        cell.textLabel?.textAlignment = .center
        return cell
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading.."
        hud.show(in: self.view)
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
            kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
            kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        CurrentUser.sendMessage(user!["uid"] as! String ,user!, "", "", CurrentUser.messages[indexPath.row], "", user!["pushid"] as! String, completion: {(success) in
             hud.dismiss()
            if success {
            }
            else{
               
              
                if (OneSignal.getPermissionSubscriptionState().permissionStatus.status == .notDetermined ||
                    OneSignal.getPermissionSubscriptionState().permissionStatus.status == .denied) {
                alert.showError("Error", subTitle: "Please enable push notification")
                }
                else{
                    alert.showError("Error", subTitle: "Cannot send, please try again.")
                }
            }
        })
       
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentUser.messages.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let block = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let alert = UIAlertController(title: "", message: "Are you sure you want to \ndelete this message?", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive, handler: {_ in
                CurrentUser.deleteMessage(CurrentUser.messages[editActionsForRowAt.row], completion:{(success) in
                    if success {
                        CurrentUser.messages.remove(at: editActionsForRowAt.row)
                    }
                    else{
                        let appearance = SCLAlertView.SCLAppearance(
                            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                            kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                            kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                            showCloseButton: true
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.showError("Error", subTitle: "cannot delete message, please try again")
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
    @objc func showPhotoGallery() {
        
        gallery = GalleryController()
        gallery.delegate = self
        self.present(gallery, animated: true, completion: nil)
    }
     func sendPhoto(_ image:UIImage) {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading.."
        hud.show(in: self.view)
        let newImg = image.resizeWithWidth(width: 375)
        StorageFirebase.uploadImage(image, CurrentUser.uid, completion:{ url in
            guard let downloadURL = url?.absoluteString else{
                hud.dismiss()
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                    kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                    kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                    showCloseButton: true
                )
                let alert = SCLAlertView(appearance: appearance)
                alert.showError("Error", subTitle: "Cannot send photo, please try again")
                return
            }
            CurrentUser.sendMessage(self.user!["uid"] as! String,self.user!, "", "", "Send you a photo", downloadURL, self.user!["pushid"] as! String, completion: {(success) in
                if success {
                    hud.dismiss()
                }
                else{
                    hud.dismiss()
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                        kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                        kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                        showCloseButton: true
                    )
                    let alert = SCLAlertView(appearance: appearance)
                    alert.showError("Error", subTitle: "Cannot send location, please try again")
                }
            })
        })
      
    }

    
}
extension SendMessageViewController:GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
        gallery.cart.images.removeAll()
        sendPhoto(images[0])
        gallery.dismiss(animated: true, completion: nil)
        gallery = nil
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        gallery.cart.images.removeAll()
        gallery.dismiss(animated: true, completion: nil)
        gallery = nil
    }
    
    
}
extension SendMessageViewController:CLLocationManagerDelegate {
    @objc func tapLocation() {
        print("click this shit")
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
                            self.isLocate = false
            locationManager.requestLocation()
        }
        else
        {
            #if debug
                println("Location services are not enabled");
            #endif
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location did update")
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        if !isLocate {
            sendLocation(coord)
            locationManager.stopUpdatingLocation()
        }
    }
    func sendLocation(_ location:CLLocationCoordinate2D) {
        isLocate = true
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading.."
        hud.show(in: self.view)
        CurrentUser.sendMessage(self.user!["uid"] as! String,user!,"\(location.latitude)", "\(location.longitude)", "Send you a location", "", self.user!["pushid"] as! String, completion: {(success) in
             hud.dismiss()
            if success {
               
            }
            else{
                
                self.isLocate = false
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                    kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                    kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                    showCloseButton: true
                )
                let alert = SCLAlertView(appearance: appearance)
                alert.showError("Error", subTitle: "Cannot send location, please try again")
            }
        })
    }
}


