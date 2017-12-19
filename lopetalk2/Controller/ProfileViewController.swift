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
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var editPhoto:UIButton!
   @IBOutlet weak var name:SkyFloatingLabelTextField!
    
    var gallery:GalleryController!
    var image = UIImage()
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController as! NavigationViewController
        nav.removeBigTitle()
        name.becomeFirstResponder()
        name.returnKeyType = UIReturnKeyType.done
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProfileViewController.finishEdit))
        self.navigationItem.title = "Edit Profile"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingToParentViewController {
        let nav = self.navigationController as! NavigationViewController
        nav.showBigTitle()
            
        }
        self.tabBarController?.tabBar.isHidden = false
    }
    @objc func openPhoto() {
        gallery = GalleryController()
        gallery.delegate = self
        self.present(gallery, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        finishEdit()
        return true
    }
    @objc func finishEdit() {
        self.navigationController?.popViewController(animated: true)
    }
}
extension ProfileViewController:GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
        gallery.cart.images.removeAll()
        gallery.dismiss(animated: true, completion: nil)
        //refreshPhoto(images[0])
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
