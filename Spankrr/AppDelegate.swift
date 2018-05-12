//
//  AppDelegate.swift
//  Spankrr
//
//  Created by Kangtle on 1/15/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import SideMenu
import GoogleMaps
import GooglePlaces
import Braintree
import SwiftyStoreKit
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var currentUser: User?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        IQKeyboardManager.sharedManager().enable = true
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        GMSServices.provideAPIKey("AIzaSyA9oOjwVFZUZANPAGbp0IIOmYy9C-tWQZQ")
        GMSPlacesClient.provideAPIKey("AIzaSyA9oOjwVFZUZANPAGbp0IIOmYy9C-tWQZQ")
        
        BTAppSwitch.setReturnURLScheme("com.abbey.Spankrr.payments")

        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        
        LOC_MANAGER.requestWhenInUseAuthorization()
        
        SideMenuManager.default.menuLeftNavigationController =
            STORYBOARD.instantiateViewController(withIdentifier: "SideMenu") as? UISideMenuNavigationController
        SideMenuManager.default.menuAnimationBackgroundColor = BACKGROUND_COLOR_3
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        if AppUserDefaults.isAcceptedTCS {
            if Auth.auth().currentUser == nil {
                let signinNC = STORYBOARD.instantiateViewController(withIdentifier: "SigninNC")
                self.window?.rootViewController = signinNC
            }else{
                let profileVC = STORYBOARD.instantiateViewController(withIdentifier: "ProfileVC")
                window?.rootViewController = UINavigationController.init(rootViewController: profileVC)
            }
        }else{
            let welcomeVC = STORYBOARD.instantiateViewController(withIdentifier: "WelcomeVC")
            self.window?.rootViewController = welcomeVC
        }
        
        return true
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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("user info: ", userInfo)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        AppUserDefaults.fcmToken = fcmToken
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will appear");
        completionHandler([.alert, .badge, .sound])
    }
}

