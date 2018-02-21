//
//  AppDelegate.swift
//  MusicApp
//
//  Created by Sergey Kargopolov on 2018-01-13.
//  Copyright © 2018 Sergey Kargopolov. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var sharedData = [String:String]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (isSuccess, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        FirebaseApp.configure()
        application.registerForRemoteNotifications()


        
        //Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil && Auth.auth().currentUser!.isEmailVerified {
                let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
                let nextView: MainPageViewController = mainStoryBoard.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                self.window?.rootViewController = nextView
            }
        //}
        return true
    }
    
    // Called when Registration is successfull
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        sharedData["apnsToken"] = token
        
        print("Registration succeeded! Token: ", token)
        
        if let instanceIdToken = InstanceID.instanceID().token() {
            print("New token \(instanceIdToken)")
            sharedData["instanceIdToken"] = instanceIdToken
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground \(notification.request.content.userInfo)")
        
        if let season = notification.request.content.userInfo["season"]
        {
            print("Season: \(season)")
        }
        
        // Reading message body
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        
        var messageBody:String?
        var messageTitle:String = "Alert"
        
        if let alertDict = dict["alert"] as? Dictionary<String, String> {
            messageBody = alertDict["body"]!
            if alertDict["title"] != nil { messageTitle  = alertDict["title"]! }
            
        } else {
            messageBody = dict["alert"] as? String
        }
        
        print("Message body is \(messageBody!) ")
        print("Message messageTitle is \(messageTitle) ")
 
        // Or let iOS to display message
        completionHandler([.alert,.sound, .badge])
       // self.showAlertAppDelegate(title: messageTitle, message: messageBody!, buttonTitle: "Ok", window: self.window!)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("Handle push from background or closed \(response.notification.request.content.userInfo)")
        updateBadgeCount()
        completionHandler()
    }
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(" Entire message \(userInfo)")
        print("Article avaialble for download: \(userInfo["articleId"]!)")
        
        let state : UIApplicationState = application.applicationState
        switch state {
        case UIApplicationState.active:
            print("If needed notify user about the message")
        default:
            print("Run code to download content")
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func showAlertAppDelegate(title: String,message : String,buttonTitle: String,window: UIWindow){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        window.rootViewController?.present(alert, animated: false, completion: nil)
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
        
        setupAppRemoteConfiguration()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func updateBadgeCount()
    {
        var badgeCount = UIApplication.shared.applicationIconBadgeNumber
        if badgeCount > 0
        {
            badgeCount = badgeCount-1
        }
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
    
    func setupAppRemoteConfiguration()
    {
        //let remoteConfigDefaultValues = ["isRegisteredButtonEnabled":"true" as NSObject]
       // RemoteConfig.remoteConfig().setDefaults(remoteConfigDefaultValues)
        RemoteConfig.remoteConfig().setDefaults(fromPlist: "RemoteConfigDefaults")
        print("Default value of isRegisteredButtonEnabled = \(RemoteConfig.remoteConfig().configValue(forKey: "isRegisteredButtonEnabled").boolValue)")
        
        // Turn on Developer Mode
        let debugSettings  = RemoteConfigSettings(developerModeEnabled: true)
        RemoteConfig.remoteConfig().configSettings = debugSettings!
        
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { (status, error) in
            if error == nil {
                RemoteConfig.remoteConfig().activateFetched()
            }
        }
        
        // Cache value will expire in 12 hours
        /*
        RemoteConfig.remoteConfig().fetch { (status, error) in
            if error == nil {
                RemoteConfig.remoteConfig().activateFetched()
            }
        }*/
    }

}

