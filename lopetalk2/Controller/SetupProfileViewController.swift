//
//  SetupProfileViewController.swift
//  lopetalk2
//
//  Created by marky RE on 5/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Gallery
import Firebase
import SCLAlertView
import ImagePicker
import JGProgressHUD
class SetupProfileViewController: UIViewController {

    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var editPhoto:UIButton!
    @IBOutlet weak var name:SkyFloatingLabelTextField!
    @IBOutlet weak var checkUsername:UIButton!
    @IBOutlet weak var done:UIButton!
    var gallery:GalleryController!
    var image = UIImage()
    var username:String!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUsername.backgroundColor = UIColor.lopeColor()
        checkUsername.setTitle("Search", for: .normal)
        checkUsername.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2.0
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.openPhoto)))
        
        
        editPhoto.setTitleColor(UIColor.lopeColor(), for: .normal)
        editPhoto.addTarget(self, action: #selector(ProfileViewController.openPhoto), for: .touchUpInside)
        
        name.placeholder = "Enter your display name"
        name.tintColor = UIColor.lopeColor()
        name.textColor = UIColor.darkGray
        name.lineColor = UIColor.lightGray
        name.selectedTitleColor = UIColor.lopeColor()
        name.selectedLineColor = UIColor.lopeColor()
        name.lineHeight = 1.0 // bottom line height in points
        name.selectedLineHeight = 2.0
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func openPhoto() {
        self.showActionSheet("Camera", "Photo Library")

//        gallery = GalleryController()
//        gallery.delegate = self
//        self.present(gallery, animated: true, completion: nil)
    }
    @IBAction func checkUsername(sender:UIButton) {
        let indicator = ActivityIndicator.showActivityIndicatory(self.view, true)
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
        self.view.endEditing(true)
        guard let temp = name.text else {
            indicator.removeFromSuperview()
            return
        }
        username = temp
        CurrentUser.isUserRegistered(username, completion: {isUserRegistered in
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                showCloseButton: true
            )
            let alert = SCLAlertView(appearance: appearance)
            if !isUserRegistered {
                indicator.removeFromSuperview()
                alert.showSuccess("Good to go!", subTitle: "You can use this username")
                self.name.textColor = UIColor.green
                UIView.animate(withDuration: 0.5, animations: {
                    self.checkUsername.isHidden = true
                })
                print("can register")
            }
            else{
                indicator.removeFromSuperview()
                alert.showError("Error", subTitle: "Username already taken")
                self.name.textColor = UIColor.red
                print("can't register")
            }
            
        })
    }
    @IBAction func done(sender:UIButton){
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading.."
        hud.show(in: self.view)
        
        if name.textColor != UIColor.green {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                showCloseButton: true
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.showError("Error", subTitle: "Please check your information again")
        }
        
        if image != nil {
              print("uploading image")
            let newImg = image.af_imageScaled(to: CGSize(width: image.size.width/2.0, height: image.size.height/2.0))
            StorageFirebase.uploadImage(newImg, CurrentUser.uid, completion:{ url in
                guard let downloadURL = url?.absoluteString else{
                    return
                }
                CurrentUser.setProfilePicture(downloadURL)
                CurrentUser.setUsername(self.username.lowercased())
                hud.dismiss()
                self.performSegue(withIdentifier: "signupSuccess", sender: self)
            })
            
        }
        else{
            CurrentUser.setUsername(self.username)
            hud.dismiss()
        }
        //self.performSegue(withIdentifier: "signupSuccess", sender: self)
    }
}

extension SetupProfileViewController:GalleryControllerDelegate {
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
extension SetupProfileViewController:ImagePickerDelegate {
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
extension SetupProfileViewController:KACircleCropViewControllerDelegate{
    func presentCircleCrop() {
        let circleCropController = KACircleCropViewController(withImage:image)
        circleCropController.delegate = self
        present(circleCropController, animated: false, completion: nil)
    }
    func circleCropDidCancel() {
        dismiss(animated: false, completion: nil)
    }
    
    func circleCropDidCropImage(_ image: UIImage) {
        self.image = image
        profileImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    
}
extension SetupProfileViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        name.textColor = UIColor.darkGray
    }
}
extension SetupProfileViewController:ActionSheetDelegate{
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
extension SetupProfileViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image0 = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.image = image0
        picker.dismiss(animated: true, completion: {
            print("present circle")
            self.presentCircleCrop()
        })
    }
}



