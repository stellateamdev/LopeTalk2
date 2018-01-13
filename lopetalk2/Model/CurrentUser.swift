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
import SCLAlertView
import OneSignal
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
    private static var _requestlist:[[String:Any]] = []
    private static var _profilePicture:String = ""
    private static var _pushid:String = ""
    private static var _notilist:[[String:Any]] = []
    static var imageCache = AutoPurgingImageCache()
    
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
    class func getNotiList(completion:@escaping(_ success:Bool) -> ()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Notifications").observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let notis = snapshot.value as? [String:Any] else {
                completion(false)
                return
            }
            notilist.removeAll()
            for noti in notis {
                print("cast noti wrong \(noti)")
                notilist.append(noti.value as! [String : Any])
                if notilist.count == notis.count {
                    completion(true)
                }
            }
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
                    print("image is here")
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
    class func queryBlockList(_ username:String,completion:@escaping(_ found:Bool)->()){
        
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

    class func sendMessage(_ uid:String, _ user:[String:Any],_ lat:String,_ long:String,_ message:String,_ picture:String,_ pushid:String, completion: @escaping(_ success:Bool) -> ()) {
        if (OneSignal.getPermissionSubscriptionState().permissionStatus.status == .notDetermined ||
            OneSignal.getPermissionSubscriptionState().permissionStatus.status == .denied) {
            completion(false)
            return
        }
        else {
            isInBlockList(uid, completion: {(isBlock) in
                if !isBlock{
                    completion(true)
                }
                else{
                    let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                    let pushToken = status.subscriptionStatus.pushToken
                    let userId = status.subscriptionStatus.userId
                    
                    if pushToken != nil {
                        let message = message
                        
                        let notificationContent = [
                            "include_player_ids": [user["pushid"] as! String],
                            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                            "headings": ["en": "LopeTalk"],
                            "subtitle": ["en": CurrentUser.username as! String],
                            // If want to open a url with in-app browser
                            //"url": "https://google.com",
                            // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                            "data": ["picture": picture,"lat":lat,"long":long],
                            //                "ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
                            "ios_badgeType": "Increase",
                            "ios_badgeCount": 1
                            ] as [String : Any]
                        
                        OneSignal.postNotification(notificationContent)
                        Database.database().reference().child("Users/\(user["uid"] as! String)/Notifications").childByAutoId().setValue(["uid":user["uid"],"profilePicture":user["profilePicture"] as! String, "username":CurrentUser.username,"message":message,"picture":picture,"lat":lat,"long":long])
                        completion(true)
                    }else{
                        print("cannot send noti \(status)")
                        completion(false)
                    }
                }
            })
        }
       
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
                Database.database().reference().child("Users/\(CurrentUser.uid)/Friendlist/\(value.keys.first!)").setValue(value.keys.first!, withCompletionBlock: {(error,ref) in
                    if error == nil {
                        Database.database().reference().child("Users/\(value.keys.first!)/Friendrequest/\(CurrentUser.uid)").setValue(CurrentUser.uid, withCompletionBlock:{(error,ref) in
                            if error == nil {
                                completion(true)
                            }
                            else{
                                completion(false)
                                return
                            }
                        })
                        
                    }
                    else{
                        completion(false)
                        return
                    }
                })
                
            }
            else{
                completion(false)
                return
            }
        })
    }
    class func getRequestList(completion: @escaping(_ success:Bool)->()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Friendrequest").observeSingleEvent(of: .value) { (snap) in
            guard let value = snap.value as? [String:Any] else {
                completion(false)
                return
            }
            requestlist.removeAll()
            for user in value {
                let uid = user
                Database.database().reference().child("Users/\(uid.value)").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let user = snapshot.value as? [String:Any] else { return }
                    requestlist.append(user)
                    
                    if value.count == requestlist.count {
                        completion(true);
                    }
                })
            }
        }
    }
    class func acceptRequest(_ uid:String,completion:@escaping(_ success:Bool)->()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Friendlist/\(uid)").setValue(uid, withCompletionBlock: {(error,ref) in
            if error != nil {
                completion(false)
                return
            }
            else{
                Database.database().reference().child("Users/\(CurrentUser.uid)/Friendrequest/\(uid)").removeValue(completionBlock:{(error,ref) in
                    if error != nil {
                        completion(false)
                        return
                    }
                    else{
                        requestlist.remove(at: requestlist.index(where: {$0["uid"] as! String == uid})!)
                        completion(true)
                    }
                })
                
            }
        })
    }
    class func rejectRequest(_ uid:String,completion:@escaping(_ success:Bool)->()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Friendrequest/\(uid)").removeValue(completionBlock:{(error,ref) in
            if error != nil {
                completion(false)
                return
            }
            else{
                requestlist.remove(at: requestlist.index(where: {$0["uid"] as! String == uid})!)
                completion(true)
            }
        })
    }
    class func blockRequest(_ uid:String,completion: @escaping(_ success:Bool) -> ()){
        Database.database().reference().child("Users/\(CurrentUser.uid)/Blocklist/\(uid)").setValue(uid, withCompletionBlock:{(error,ref) in
            if error != nil {
                completion(false)
            }
            else{
                Database.database().reference().child("Users/\(CurrentUser.uid)/Friendrequest/\(uid)").removeValue(completionBlock: {(error,ref) in
                    if error != nil {
                        completion(false)
                    }
                    else{
                        completion(true)
                    }
                })
                
                
            }
        })
    }
    class func removeUser() {
       uid = ""
       email = ""
    username = ""
        friendlistUid = []
        blocklistUid = []
        profilePicture = ""
        pushid = ""
        notilist.removeAll()
        
        friendlist.removeAll()
        blocklist.removeAll()
        requestlist.removeAll()
        friendlistUid.removeAll()
        blocklistUid.removeAll()
        messages.removeAll()
        
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
        profilePicture = url
        
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
    class func isInBlockList(_ uid: String, completion: @escaping (_ exists: Bool) -> ()) {
        Database.database().reference().child("Users/\(CurrentUser.uid)/Blocklist").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    class func setUsername(_ username:String){
        self.username = username
        Database.database().reference().child("Users/\(_uid)/username").setValue(username)
        Database.database().reference().child("Users/\(_uid)/displayName").setValue(username)
    }
    class func resetPassword() {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold),
            kTextFont:  UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
            kButtonFont:  UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold),
            showCloseButton: true
        )
        let alert = SCLAlertView(appearance: appearance)
        Auth.auth().sendPasswordReset(withEmail: CurrentUser.email, completion: { (error) in
            if error != nil {
                alert.showError("Error", subTitle: "Cannot sennd reset password email, please try again")
            }
            else{
                alert.showSuccess("Success", subTitle: "reset password email sent, please check your email")
            }
        })

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
    static var profilePicture:String {
        get{
            return _profilePicture
        }set{
            _profilePicture = newValue
        }
    }
    static var requestlist:[[String:Any]] {
        get{
            return _requestlist
        }
        set{
            _requestlist = newValue
        }
    }
    static var pushid:String {
        get{
            return _pushid
        }
        set{
            _pushid = newValue
        }
    }
    static var notilist:[[String:Any]]{
        get{
            return _notilist
        }
        set{
            _notilist = newValue
        }
    }
}
