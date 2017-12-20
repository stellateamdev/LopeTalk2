//
//  LogInViewController.swift
//  lopetalk2
//
//  Created by marky RE on 20/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import LGButton

class LoginViewController: UIViewController {
    @IBOutlet weak var headerView:LGButton!
    @IBOutlet weak var username:UITextField!
    @IBOutlet weak var password:UITextField!
    @IBOutlet weak var loginBtn:LGButton!
    @IBOutlet weak var signupLabel:UILabel!
    @IBOutlet weak var signup:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.bgColor = UIColor.lopeColor()
        loginBtn.titleColor = UIColor.white
        loginBtn.titleString = "Login"
        loginBtn.cornerRadius = 5.0
        
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
    @IBAction func signin() {
        self.performSegue(withIdentifier: "signinSuccess", sender: self)
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
