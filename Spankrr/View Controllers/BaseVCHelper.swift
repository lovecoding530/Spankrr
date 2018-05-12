//
//  BaseVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/17/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import SideMenu
import Pulley
import Firebase

class BaseVCHelper : NSObject {

    var menuButton: UIButton!
    var messageButton: UIButton!
    var dungeonButton: UIButton!
    var whipButton: UIButton!
    var viewController: UIViewController!

    func setupNavigationBar(viewController: UIViewController) {
        self.viewController = viewController
//        self.viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.viewController.navigationController?.navigationBar.shadowImage = UIImage()
//        self.viewController.navigationController?.navigationBar.isTranslucent = true
        self.viewController.navigationController?.navigationBar.barTintColor = BACKGROUND_COLOR_3
        self.viewController.view.backgroundColor = BACKGROUND_COLOR_2
        
        menuButton = UIButton()
        menuButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.setImage(#imageLiteral(resourceName: "menu"), for: .normal)
        menuButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 10)
        menuButton.addTarget(self, action: #selector(onPressedMenuButton), for: .touchUpInside)
        
        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.viewController.navigationItem.leftBarButtonItem = menuBarButtonItem
        
        messageButton = UIButton()
        messageButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        messageButton.imageView?.contentMode = .scaleAspectFit
        messageButton.setImage(#imageLiteral(resourceName: "chat").withRenderingMode(.alwaysTemplate), for: .normal)
        messageButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 10)
        messageButton.addTarget(self, action: #selector(onPressedChatButton), for: .touchUpInside)
        let messageButtonItem = UIBarButtonItem(customView: messageButton)
        if let uid = Auth.auth().currentUser?.uid, let fcmToken = AppUserDefaults.fcmToken {
            FirebaseHelper.userFcmTokensRef.child("\(uid)/\(fcmToken)").observe(.value, with: { (snapshot) in
                if let badgeNumber = snapshot.value as? Int {
                    if badgeNumber > 0 {
                        messageButtonItem.setBadge(number: badgeNumber, offset: CGPoint(x: -10, y: 8))
                    }
                }
            })
        }

        dungeonButton = UIButton()
        dungeonButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        dungeonButton.imageView?.contentMode = .scaleAspectFit
        dungeonButton.setImage(#imageLiteral(resourceName: "dungeon").withRenderingMode(.alwaysTemplate), for: .normal)
        dungeonButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 10)
        dungeonButton.addTarget(self, action: #selector(onPressedDungeonButton), for: .touchUpInside)
        let dungeonButtonItem = UIBarButtonItem(customView: dungeonButton)
        
        whipButton = UIButton()
        whipButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        whipButton.imageView?.contentMode = .scaleAspectFit
        whipButton.setImage(#imageLiteral(resourceName: "whip-locator").withRenderingMode(.alwaysTemplate), for: .normal)
        whipButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        whipButton.addTarget(self, action: #selector(onPressedWhipButton), for: .touchUpInside)
        
        self.viewController.navigationItem.rightBarButtonItems = [
            dungeonButtonItem,
            messageButtonItem
        ]
        self.viewController.navigationItem.titleView = whipButton
        
        print(type(of: self.viewController))
        
        switch self.viewController {
        case is FindKinkMatchVC:
            whipButton.tintColor = RED_COLOR
            messageButton.tintColor = .white
            dungeonButton.tintColor = .white
            break
        case is MessagesVC:
            whipButton.tintColor = .white
            messageButton.tintColor = RED_COLOR
            dungeonButton.tintColor = .white
            break
        case is DungeonFinderRootVC:
            whipButton.tintColor = .white
            messageButton.tintColor = .white
            dungeonButton.tintColor = RED_COLOR
            break
        default:
            whipButton.tintColor = .white
            messageButton.tintColor = .white
            dungeonButton.tintColor = .white
            break
        }
    }

    func onPressedMenuButton() {
        let sideMenu = SideMenuManager.default.menuLeftNavigationController
        self.viewController.present(sideMenu!, animated: true, completion: nil)
    }
    
    func onPressedChatButton() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let uid = APPDELEGATE.currentUser?.uid, let fcmToken = AppUserDefaults.fcmToken {
            FirebaseHelper.userFcmTokensRef.child("\(uid)/\(fcmToken)").setValue(0)
        }
        let messageVC = STORYBOARD.instantiateViewController(withIdentifier: "MessagesVC")
        APPDELEGATE.window?.rootViewController = UINavigationController.init(rootViewController: messageVC)
    }
    
    func onPressedDungeonButton() {
        let dungeonVC = STORYBOARD.instantiateViewController(withIdentifier: "DungeonFinderRootVC")
        APPDELEGATE.window?.rootViewController = UINavigationController.init(rootViewController: dungeonVC)
    }

    func onPressedWhipButton() {
        let findVC = STORYBOARD.instantiateViewController(withIdentifier: "FindKinkMatchVC")
        APPDELEGATE.window?.rootViewController = UINavigationController.init(rootViewController: findVC)
    }
}
