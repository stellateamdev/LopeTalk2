//
//  Extension.swift
//  lopetalk2
//
//  Created by marky RE on 16/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func checkmarkGreen() -> UIColor {
        return UIColor(red: 116/255.0, green: 178/255.0, blue: 64/255.0, alpha: 1)
    }
    class func lopeColor() -> UIColor {
        return UIColor(red: 88/255.0, green: 180/255.0, blue: 198/255.0, alpha: 1)
    }
    class func tableViewBackgroundColor() -> UIColor {
        return UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
    }
    class func editGreyColor() -> UIColor {
        return UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
    }
}
extension UIFont {
    
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
}

extension UIViewController {
    
    class func getStoryboardInstance(_ identifier:String) -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    func pushView(_ identifier:String){
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController?.pushViewController(view, animated: true)
    }
}
extension UIDevice {
    class var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}
extension UIImage {
    class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


