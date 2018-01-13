//
//  LogInViewController.swift
//  lopetalk2
//
//  Created by marky RE on 20/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import LGButton
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import SCLAlertView
import JGProgressHUD
class LoginViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var headerView:LGButton!
    @IBOutlet weak var username:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var loginBtn:LGButton!
    @IBOutlet weak var signupLabel:UILabel!
    @IBOutlet weak var signup:UIButton!
    @IBOutlet weak var fbSignin:UIButton!
    @IBOutlet weak var googleSignin:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self

        loginBtn.bgColor = UIColor.lopeColor()
        loginBtn.titleColor = UIColor.white
        loginBtn.titleString = "Login"
        loginBtn.cornerRadius = 5.0
        
        fbSignin.layer.cornerRadius = 5.0
        fbSignin.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        googleSignin.layer.cornerRadius = 5.0
        googleSignin.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        username.backgroundColor = UIColor.tableViewBackgroundColor()
        username.borderStyle = .roundedRect
        username.placeholder = "Email"
        username.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        password.backgroundColor = UIColor.tableViewBackgroundColor()
        password.borderStyle = .roundedRect
        password.placeholder = "Password"
        password.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        password.isSecureTextEntry = true
        
        signupLabel.text = "Want to join LopeTalk?"
        signupLabel.textColor = UIColor.lightGray
        
        signup.setTitle("Sign up.", for: .normal)
        signup.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
//        username.layer.borderColor = UIColor.darkGray
//        username.layer.borderWidth = 2.0
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signin() {
         self.view.endEditing(true)
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Logging in.."
        hud.show(in: self.view)
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
            kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
            kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        guard let email = username.text else{
            hud.dismiss()
            alert.showError("Error", subTitle: "Please enter your email")
            return
        }
        guard let password = password.text else {
            hud.dismiss()
            alert.showError("Error", subTitle: "Please enter your password")
            return
        }
         Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                hud.dismiss()
                alert.showError("Error", subTitle: (error?.localizedDescription)!)
            }
            else {
                guard let uid = user?.uid else {
                    hud.dismiss()
                    print("uid error")
                    return
                }
                guard let email = user?.email else {
                    hud.dismiss()
                    print("email error")
                    return
                }
                CurrentUser.uid = uid
                CurrentUser.email = email
                Database.database().reference().child("Users/\(CurrentUser.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                    guard let user = snapshot.value as? [String:Any] else {
                        hud.dismiss()
                        alert.showError("Error", subTitle: ("There's an error, please try agian"))
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
                            self.present(view, animated: true, completion: nil)
                        } catch let signOutError as NSError {
                            alert.showError("Error", subTitle: "Error signing out, please try again.")
                            print ("Error signing out: %@", signOutError)
                        }
                        return
                    }
                    guard let username = user["username"] as? String else {
                        hud.dismiss()
                        alert.showError("Error", subTitle: ("There's an error, please try agian"))
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
                            self.present(view, animated: true, completion: nil)
                        } catch let signOutError as NSError {
                            
                            alert.showError("Error", subTitle: "Error signing out, please try again.")
                            print ("Error signing out: %@", signOutError)
                        }
                        return
                    }
                    guard let profilePicture = user["profilePicture"] as? String else {
                        hud.dismiss()
                        alert.showError("Error", subTitle: ("There's an error, please try agian"))
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                            let view = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
                            self.present(view, animated: true, completion: nil)
                        } catch let signOutError as NSError {
                            
                            alert.showError("Error", subTitle: "Error signing out, please try again.")
                            print ("Error signing out: %@", signOutError)
                        }
                        return
                    }
                    CurrentUser.username = username
                    self.performSegue(withIdentifier: "signinSuccess", sender: self)
                    
                })
              
            }
        }
    }
    
    @IBAction func googleSignin(sender:UIButton) {
        
         self.view.endEditing(true)
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        self.signInFirebaseWithCredential(credential)
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
         self.view.endEditing(true)
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if  error != nil {
                print("Failed to login: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            self.signInFirebaseWithCredential(credential)
        }
    }
    func signInFirebaseWithCredential(_ credential:AuthCredential){
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading.."
        hud.show(in: self.view)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                hud.dismiss()
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: {
                    CurrentUser.removeUser()
                })
                return
            }
            guard let uid = user?.uid else {
                hud.dismiss()
                print("uid error")
                return
            }
            guard let email = user?.email else {
                hud.dismiss()
                print("email error")
                return
            }
            CurrentUser.uid = uid
            CurrentUser.email = email
            Database.database().reference().child("Users/\(uid)").observeSingleEvent(of: .value, with: {(snapshot) in
                if !snapshot.exists() {
                    hud.dismiss()
                    CurrentUser.register(user!)
                }
                hud.dismiss()
                 self.performSegue(withIdentifier: "signinSuccess", sender: self)
            })
            
           
            
        }
    }

}
