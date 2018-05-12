//
//  MenuTableVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/19/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import SideMenu
import Firebase

class MenuTableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lastIndex = self.tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastIndex {
            do {
                if let fcmToken = AppUserDefaults.fcmToken {
                    FirebaseHelper.userFcmTokensRef.child("\(APPDELEGATE.currentUser?.uid ?? "")/\(fcmToken)").setValue(nil)
                }
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            SideMenuManager.default.menuLeftNavigationController?.dismiss(animated: true){
                let signinNC = STORYBOARD.instantiateViewController(withIdentifier: "SigninNC")
                APPDELEGATE.window?.rootViewController = signinNC
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
