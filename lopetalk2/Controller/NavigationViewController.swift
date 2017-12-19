//
//  NavigationViewController.swift
//  lopetalk2
//
//  Created by marky RE on 17/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    var titleLabel:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let bar = self.navigationBar
        bar.shadowImage = UIImage()
        bar.setBackgroundImage(UIImage(), for: .default)
        bar.isTranslucent = false
        let titleFrame = CGRect(x: 15, y: (bar.frame.height)/1.2, width: 250, height: 40)
        titleLabel = UILabel(frame: titleFrame)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: UIFont.Weight.heavy)
        bar.addSubview(titleLabel)
        bar.tintColor = UIColor.white
        bar.barTintColor = UIColor.lopeColor()
        
        // Do any additional setup after loading the view.
    }
    func changeFontSize(_ size:Int) {
        titleLabel.font = UIFont.systemFont(ofSize: CGFloat(size), weight: UIFont.Weight.heavy)
    }
    func removeBigTitle() {
        self.titleLabel.isHidden = true
    }
    func showBigTitle() {
        self.titleLabel.isHidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
