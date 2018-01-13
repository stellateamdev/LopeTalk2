//
//  ProfileViewController.swift
//  lopetalk2
//
//  Created by marky RE on 18/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Gallery
import Firebase
import SCLAlertView
import Alamofire
import AlamofireImage
import ImagePicker
import JGProgressHUD
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var currentUsername: UILabel!
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var editPhoto:UIButton!
    @IBOutlet weak var name:SkyFloatingLabelTextField!
    
    var gallery:GalleryController!
    var image = UIImage()
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController as! NavigationViewController
        nav.removeBigTitle()
        
        name.returnKeyType = UIReturnKeyType.done
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //name.becomeFirstResponder()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2.0
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.openPhoto)))
        
        editPhoto.setTitleColor(UIColor.lopeColor(), for: .normal)
        editPhoto.addTarget(self, action: #selector(ProfileViewController.openPhoto), for: .touchUpInside)
          profileImage.image = UIImage(named:"profileLoad")

        self.currentUsername.text = "Your username is \(CurrentUser.username)"
        
        
        name.placeholder = "Enter your display name"
        name.tintColor = UIColor.lopeColor()
        name.textColor = UIColor.darkGray
        name.lineColor = UIColor.lightGray
        name.selectedTitleColor = UIColor.lopeColor()
        name.selectedLineColor = UIColor.lopeColor()
        name.lineHeight = 1.0 // bottom line height in points
        name.selectedLineHeight = 2.0
        CurrentUser.getDisplayName(completion: {(displayName) in
            self.name.text = displayName
        })
        CurrentUser.getProfilePicture(profileImage.frame.size, completion: {(image) in
            self.profileImage.image = image
        })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProfileViewController.finishEdit))
        self.navigationItem.title = "Edit Profile"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingToParentViewController {
        let nav = self.navigationController as! NavigationViewController
        nav.showBigTitle()
            
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    @objc func openPhoto() {
        self.showActionSheet("Camera", "Photo Library")
        
        //        gallery = GalleryController()
        //        gallery.delegate = self
        //        self.present(gallery, animated: true, completion: nil)
    }
    
//    func textFieldShouldReturn(textField: UITextField!) -> Bool {
//        finishEdit()
//        return true
//    }
    
    @objc func finishEdit() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading.."
        hud.show(in: self.view)
        if name.text == "" {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                showCloseButton: true
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.showError("Error", subTitle: "Please add your display name")
            
            return
        }

        Database.database().reference().child("Users/\(CurrentUser.uid)/displayName").setValue(name.text, withCompletionBlock: {(error,ref) in
            if error != nil {
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                    kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                    kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                    showCloseButton: true
                )
                let alert = SCLAlertView(appearance: appearance)
                hud.dismiss()
                 alert.showError("Error", subTitle: "Cannot change display name, please try again later")
            }
            else{
                if self.image != nil {
                    print("uploading image")
                    let newImg = self.image.resizeWithWidth(width: 150)
                    StorageFirebase.uploadImage(newImg!, CurrentUser.uid, completion:{ url in
                        guard let downloadURL = url?.absoluteString else{
                            return
                        }
                        CurrentUser.setProfilePicture(downloadURL)
                        hud.dismiss()
                         self.navigationController?.popViewController(animated: true)
                    })
                    
                }
               
            }
        })
    }
}

extension ProfileViewController:GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
        gallery.cart.images.removeAll()
        gallery.dismiss(animated: true, completion: nil)
        image = images[0]
        gallery = nil
        presentCircleCrop()
        
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
extension ProfileViewController:ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
        imagePicker.dismiss(animated: true, completion: {
            self.image = images[0]
            self.presentCircleCrop()
        })
        
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
extension ProfileViewController:KACircleCropViewControllerDelegate{
    func presentCircleCrop() {
        let circleCropController = KACircleCropViewController(withImage:image)
        circleCropController.delegate = self
        present(circleCropController, animated: false, completion: nil)
    }
    func circleCropDidCancel() {
        dismiss(animated: false, completion: nil)
    }
    
    func circleCropDidCropImage(_ image: UIImage) {
        profileImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    
}
extension ProfileViewController:ActionSheetDelegate{
    func thirdAction() {}
    
    func firstAction() {
        var configuration = Configuration()
        configuration.doneButtonTitle = "Done"
        configuration.noImagesTitle = "Sorry! There are no images here"
        configuration.recordLocation = false
        let imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func secondAction() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func showActionSheet(_ first:String,_ second:String) {
        self.view.endEditing(true)
        let acsheetModel = ActionSheetModel()
        acsheetModel.delegate = self
        acsheetModel.firstBtnTitle = first
        acsheetModel.secondBtnTitle = second
        let acsheet = acsheetModel.setUp(false)
        acsheet.show()
    }
}
extension ProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image0 = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.image = image0
        picker.dismiss(animated: true, completion: {
            print("present circle")
              self.presentCircleCrop()
        })
      
        
        
    }
}




