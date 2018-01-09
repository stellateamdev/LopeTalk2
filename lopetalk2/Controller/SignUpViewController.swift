//
//  loginViewController.swift
//  lopetalk2
//
//  Created by marky RE on 20/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import LGButton
import Firebase
import SCLAlertView
import FBSDKLoginKit
import GoogleSignIn
class SignupViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var headerView:LGButton!
    @IBOutlet weak var username:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var confirmPassword:UITextField!
    @IBOutlet weak var signupBtn:LGButton!
    @IBOutlet weak var loginLabel:UILabel!
    @IBOutlet weak var login:UIButton!
    @IBOutlet weak var fbSignin:UIButton!
    @IBOutlet weak var googleSignin:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        fbSignin.layer.cornerRadius = 5.0
        fbSignin.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        googleSignin.layer.cornerRadius = 5.0
        googleSignin.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        signupBtn.bgColor = UIColor.lopeColor()
        signupBtn.titleColor = UIColor.white
        signupBtn.titleString = "Signup"
        signupBtn.cornerRadius = 5.0
        
        username.backgroundColor = UIColor.tableViewBackgroundColor()
        username.borderStyle = .roundedRect
        username.placeholder = "Email"
        username.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        password.backgroundColor = UIColor.tableViewBackgroundColor()
        password.borderStyle = .roundedRect
        password.placeholder = "Password"
        password.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        password.isSecureTextEntry = true
        
        confirmPassword.backgroundColor = UIColor.tableViewBackgroundColor()
        confirmPassword.borderStyle = .roundedRect
        confirmPassword.placeholder = "Confirm password"
        confirmPassword.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        confirmPassword.isSecureTextEntry = true
        
        loginLabel.text = "Have an account?"
        loginLabel.textAlignment = .center
        loginLabel.textColor = UIColor.lightGray
        
        login.setTitle("Sign in.", for: .normal)
        login.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
      
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
    @IBAction func testSetup() {
        self.performSegue(withIdentifier: "setupProfile", sender: self)
    }
    @IBAction func signup() {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
            kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
            kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        guard let email = username.text else{
            alert.showError("Error", subTitle: "Please enter your email")
            return
        }
        guard let password = password.text else {
            alert.showError("Error", subTitle: "Please enter your password")
            return
        }
        guard let confirmPassword = confirmPassword.text else {
            alert.showError("Error", subTitle: "Please confirm your password")
            return
        }
        if password != confirmPassword {
            alert.showError("Error", subTitle: "Your passwords do not match")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
           
            if error != nil {
                alert.showError("Error", subTitle: (error?.localizedDescription)!)
            }
            else {
                guard let uid = user?.uid else {
                    print("uid error")
                    return
                }
                guard let email = user?.email else {
                    print("email error")
                    return
                }
                CurrentUser.uid = uid
                CurrentUser.email = email
                
                let appearanceSuccess = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
                    kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
                    kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
                    showCloseButton: false
                )
                let alertSuccess = SCLAlertView(appearance: appearanceSuccess)
                alertSuccess.addButton("Thanks!", action: {
                    CurrentUser.register(user!)
                    self.performSegue(withIdentifier: "setupProfile", sender: self)
                })
                
                alertSuccess.showSuccess("Congratulations!", subTitle: "You've successfully signup to LopeTalk")
                
            }
        }
       
    }
    
    @IBAction func googleSignin(sender:UIButton) {
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
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            guard let uid = user?.uid else {
                print("uid error")
                return
            }
            guard let email = user?.email else {
                print("email error")
                return
            }
            CurrentUser.uid = uid
            CurrentUser.email = email
            CurrentUser.register(user!)
            self.performSegue(withIdentifier: "setupProfile", sender: self)
            
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

