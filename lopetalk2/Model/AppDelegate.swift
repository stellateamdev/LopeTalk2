//
//  AppDelegate.swift
//  lopetalk2
//
//  Created by marky RE on 16/12/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import UserNotifications
import GoogleSignIn
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, OSSubscriptionObserver {
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        // Example of detecting answering the permission prompt
            if stateChanges.from.subscribed == false && stateChanges.to.subscribed {

                let userID = stateChanges.to.userId
                let pushToken = stateChanges.to.pushToken
                print("pushToken = \(String(describing: pushToken))")

                if pushToken != nil {
                    if let playerID = userID {
                        CurrentUser.pushid = playerID
                        Database.database().reference().child("Users/\(CurrentUser.uid)/pushid").setValue(playerID, withCompletionBlock: {(error,ref) in
                            if error != nil {
                                return
                            }
                            else{
                                print("push noti \(OneSignal.getPermissionSubscriptionState())")
                            }
                        })
                    }
                }
            }
        }
    

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification: \(notification!.payload.notificationID)")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            let fullMessage = payload.body!
            print("Message = \(fullMessage)")
            let title = payload.title
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    if self.window!.rootViewController as? UITabBarController != nil {
                        var tababarController = self.window!.rootViewController as! UITabBarController
                        tababarController.selectedIndex = 1
                    }
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                     kOSSettingsKeyInAppLaunchURL: true]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "452b985a-33bb-4a43-ac60-629feb07f04c",
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
      // OneSignal.add(self as! OSPermissionObserver)
//        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
//
//        OneSignal.initWithLaunchOptions(launchOptions,
//                                        appId: "452b985a-33bb-4a43-ac60-629feb07f04c",
//                                        handleNotificationAction: nil,
//                                        settings: onesignalInitSettings)
//
//        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        let all = Database.database().reference()
        all.keepSynced(true)
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if !CurrentUser.isSignin() {
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "login")
                self.window?.rootViewController = initialViewController
            }else {
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabView")
                self.window?.rootViewController = initialViewController
            }
        self.window?.makeKeyAndVisible()
        return true
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

// [START ios_10_message_handling]
// [END ios_10_message_handling]

