//
//  ActionSheetModel.swift
//  lopetalk2
//
//  Created by marky RE on 17/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import Foundation
import Hokusai
import UIKit

protocol ActionSheetDelegate:class {
    func firstAction()-> Void
    func secondAction() -> Void
    func thirdAction() -> Void
}


class ActionSheetModel {
    
    weak var delegate:ActionSheetDelegate?
    let hokusai = Hokusai()
    var firstBtnTitle:String!
    var secondBtnTitle:String!
    var thirdBtnTitle:String!
    func setUp(_ third:Bool) -> Hokusai {
        
        hokusai.addButton(firstBtnTitle) {

            self.delegate?.firstAction()
        }
        hokusai.addButton(secondBtnTitle){
            self.delegate?.secondAction()
        }
        if third {
            hokusai.addButton(thirdBtnTitle){
                self.delegate?.thirdAction()
            }
        }
        
        hokusai.cancelButtonTitle = "Cancel"
        
        hokusai.cancelButtonAction = {
        }
        hokusai.fontName = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium).fontName
        
        hokusai.colorScheme = HOKColorScheme.lopetalk
        return hokusai
    }
   
}
