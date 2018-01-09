//
//  CurrentUser.swift
//  lopetalk2
//
//  Created by marky RE on 4/1/2561 BE.
//  Copyright © 2561 marky RE. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import AlamofireImage

typealias signInCompletion = (Bool) -> Void

class CurrentUser {
    
    private static var _uid:String = ""
    private static var _email:String = ""
    private static var _username:String = ""
    private static var _friendlist:[[String:Any]] = []
    private static var _friendlistUid:[String] = []
    private static var _messages:[String] = []
    private static var _blocklist:[[String:Any]] = []
    private static var blocklistUid:[String] = []
    
    class func isSignin() -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        Database.database().reference().child("Users/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String:Any] else { return }
            self.email = value["email"] as! String
            self.uid = uid
            self.username = value["username"] as! String
        }
        return true
    }
    class func getDisplayName(completion: @escaping(_ name:String) -> ()){
        Database.database().reference().child("Users/\(CurrentUser.uid)/displayName").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let name = snapshot.value as? String else {
                completion("")
                return
            }
            completion(name)
        })
    }

    class func getBlockList(completion: @escaping(_ success:Bool) -> ()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Blocklist").observeSingleEvent(of: .value) { (snap) in
            guard let value = snap.value as? [String:Any] else {
                completion(false)
                return
            }
            blocklist.removeAll()
            for user in value {
                let uid = user
                blocklistUid.append(uid.value as! String)
                Database.database().reference().child("Users/\(uid.value)").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let user = snapshot.value as? [String:Any] else { return }
                    blocklist.append(user)
                    
                    if value.count == blocklist.count {
                        
                        completion(true);
                    }
                })
            }
        }
    }
    
    class func deleteUser(_ uid:String,completion:@escaping(_ success:Bool) -> ()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Blocklist/\(uid)").removeValue(completionBlock: {(error,ref) in
            if error != nil {
                completion(false)
            }
            else{
                blocklist.remove(at: blocklist.index(where: {$0["uid"] as! String == uid})!)
                completion(true)
            }
        })
    }
    class func unblockUser(_ uid:String,completion: @escaping(_ success:Bool) -> ()){
        Database.database().reference().child("Users/\(CurrentUser.uid)/Friendlist/\(uid)").setValue(uid, withCompletionBlock:{(error,ref) in
            if error != nil {
                completion(false)
            }
            else{
                Database.database().reference().child("Users/\(CurrentUser.uid)/Blocklist/\(uid)").removeValue(completionBlock: {(error,ref) in
                    if error != nil {
                        completion(false)
                    }
                    else{
                        friendlist.append(blocklist[blocklist.index(where: {$0["uid"] as! String == uid})!])
                        blocklist.remove(at:blocklist.index(where: {$0["uid"] as! String == uid})!)
                        completion(true)
                    }
                })
            }
        })
    }
    class func blockUser(_ uid:String,completion: @escaping(_ success:Bool) -> ()){
        Database.database().reference().child("Users/\(CurrentUser.uid)/Blocklist/\(uid)").setValue(uid, withCompletionBlock:{(error,ref) in
            if error != nil {
                completion(false)
            }
            else{
                Database.database().reference().child("Users/\(CurrentUser.uid)/Friendlist/\(uid)").removeValue(completionBlock: {(error,ref) in
                    if error != nil {
                        completion(false)
                    }
                    else{
                        friendlist.remove(at: friendlist.index(where: {$0["uid"] as! String == uid})!)
                        completion(true)
                    }
                })
                
                
            }
        })
    }
    class func deleteMessage(_ message:String,completion:@escaping(_ success:Bool) ->()){
        Database.database().reference().child("Users/\(CurrentUser.uid)/Messages").queryOrderedByKey().queryEqual(toValue: message).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    guard let key = snapshot.key as? String else {
                        completion(false)
                        return
                    }
                    print("checkkey \(key)")
                    Database.database().reference().child("Users/\(CurrentUser.uid)/Messages/\(key)").removeValue(completionBlock: {(error,ref) in
                        if error != nil {
                            completion(false)
                            return
                        }
                        else{
                        completion(true)
                        }
                    })
                }
            
        })
    }
    class func getProfilePicture(_ size:CGSize,completion: @escaping(_ image:UIImage) -> ()){
        Database.database().reference().child("Users/\(CurrentUser.uid)/profilePicture").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let imageURL = snapshot.value as? String else {
                completion(UIImage())
                return
            }
            Alamofire.request(imageURL).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    let aspectScaledToFitImage = image.af_imageAspectScaled(toFit: size)
                    completion(aspectScaledToFitImage)
                    
                    
                }
            }
            
            
        })
    }
    class func getFriendlist(completion: @escaping (_ friendlist:[[String:Any]]) -> ())  {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Friendlist").observeSingleEvent(of: .value) { (snap) in
            guard let value = snap.value as? [String:Any] else {
                return
            }
            friendlist.removeAll()
            for user in value {
                let uid = user
                friendlistUid.append(uid.value as! String)
                Database.database().reference().child("Users/\(uid.value)").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let user = snapshot.value as? [String:Any] else { return }
                    friendlist.append(user)
                    
                    if value.count == friendlist.count {
                        completion(friendlist);
                    }
                })
            }
        }
    }
    class func addMessage(_ message:String, completion: @escaping (_ finish:Bool) -> ()){
        Database.database().reference().child("Users/\(CurrentUser.uid)/Messages").childByAutoId().setValue(message, withCompletionBlock:{ (error , ref) in
            if error != nil {
            completion(false)
            }
            else{
            completion(true)
            }
        })
    }
    class func getMessageList(completion: @escaping (_ finish:Bool) -> ()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Messages").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? [String:Any] else {
                completion(false)
                return
            }
           
            messages.removeAll()
            for message in value {
                messages.append(message.value as! String)
            }
            completion(true)
            
            })
    }
    class func addFriend(_ username:String,completion: @escaping (_ finish:Bool) -> ()) {
        Database.database().reference().child("Users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                guard let value = snapshot.value as? [String:Any] else { return }
                friendlist.append(value as! [String:Any])
                Database.database().reference().child("Users/\(CurrentUser.uid)/Friendlist/\(value.keys.first!)").setValue(value.keys.first!)
                completion(true)
            }
            else{
                completion(false)
            }
        })
    }
    
    class func register(_ user:User,_ username:String?="", _ displayname:String?="") {
        let name = username
        Database.database().reference().child("Users").child(user.uid).setValue([
            "email":user.email,
            "username":username,
            "displayName":name,
            "profilePicture":user.photoURL?.absoluteString,
            "uid":user.uid
            ])
    }
    class func setProfilePicture(_ url:String){
        Database.database().reference().child("Users/\(_uid)/profilePicture").setValue(url)
        
    }
    class func isUserRegistered(_ username: String, completion: @escaping (_ exists: Bool) -> ()) {
        Database.database().reference().child("Users").queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    class func setUsername(_ username:String){
        _username = username
        Database.database().reference().child("Users/\(_uid)/username").setValue(username)
        Database.database().reference().child("Users/\(_uid)/displayName").setValue(username)
    }
    static var uid:String{
        get{
            if _uid == "" {
                return (Auth.auth().currentUser?.uid)!
            }
            return _uid
        }
        set{
            _uid = newValue
        }
    }
    static var friendlist:[[String:Any]] {
        get{
            return _friendlist
        }
        set{
            _friendlist = newValue
        }
    }
    static var blocklist:[[String:Any]] {
        get{
            return _blocklist
        }
        set{
            _blocklist = newValue
        }
    }
    static var friendlistUid:[String] {
        get{
            return _friendlistUid
        }
        set{
            _friendlistUid = newValue
        }
    }
    static var email:String {
        get{
            return _email
        }
        set{
            _email = newValue
        }
    }
    static var messages:[String] {
        get{
            return _messages
        }
        set{
            _messages = newValue
        }
    }
    static var username:String {
        get{
            return _username
        }set{
            _username = newValue
        }
    }
}
