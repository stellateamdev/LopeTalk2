//
//  ActivityIndicator.swift
//  lopetalk2
//
//  Created by marky RE on 5/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import Foundation
import UIKit

class ActivityIndicator {
    class func showActivityIndicatory(_ view:UIView?=nil,_ isCenter:Bool?=false) -> UIActivityIndicatorView{
        let indicator = UIActivityIndicatorView()
        indicator.frame = CGRect.init(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        indicator.hidesWhenStopped = true
        if isCenter! {
            indicator.center = CGPoint(x: (view?.center.x)!, y: (view?.center.y)!-50)
        }
        indicator.startAnimating()
        indicator.layer.cornerRadius = 5.0
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.backgroundColor = UIColor.gray
        return indicator
    }
}
