//
//  SlidingTabBarItem.swift
//  
//
//  Created by Adam Bardon on 25/02/16.
//  Copyright © 2016 Adam Bardon. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php


import UIKit

public class SlidingTabBarItem: UIView {
    
    public var iconView: UIImageView!
    
    public init (frame : CGRect, tintColor: UIColor, item: UITabBarItem) {
        super.init(frame : frame)
        
        guard let image = item.image else {
            fatalError("SlidingTabBar: add images to tabbar items")
        }
        
        // create imageView centered within a container
        iconView = UIImageView(frame: CGRect(x: (self.frame.width-image.size.width)/2, y: (self.frame.height-image.size
            .height)/2 , width: self.frame.width, height: self.frame.height))        
        iconView.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        iconView.tintColor = tintColor
        iconView.sizeToFit()
        
        self.addSubview(iconView)
    }
    
    public convenience init () {
        self.init(frame:CGRect.zero,tintColor:UIColor.white,item:UITabBarItem())
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
