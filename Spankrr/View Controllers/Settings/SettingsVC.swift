//
//  SettingsVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/17/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import MBProgressHUD

class SettingsVC: UIViewController {
    
    let baseVCHelper = BaseVCHelper()

    @IBOutlet weak var emailField: UnderLineTextField!
    @IBOutlet weak var currentPasswordField: PasswordTextField!
    @IBOutlet weak var newPasswordField: PasswordTextField!
    @IBOutlet weak var verifyPasswordField: PasswordTextField!
    
    @IBOutlet weak var currentStateLabel: UILabel!
    @IBOutlet weak var cloakBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseVCHelper.setupNavigationBar(viewController: self)
        
        if let user = APPDELEGATE.currentUser {
            emailField.text = user.email
            emailField.isEnabled = false
        }
        
        updateCurrentState()
        // Do any additional setup after loading the view.
    }
    
    func updateCurrentState(){
        if let user = APPDELEGATE.currentUser {
            if user.isVisible {
                currentStateLabel.text = "Your account is currently visible"
                cloakBtn.setTitle("Cloak Account", for: .normal)
                cloakBtn.backgroundColor = RED_COLOR
            }else{
                currentStateLabel.text = "Your account is currently invisible"
                cloakBtn.setTitle("Uncloak Account", for: .normal)
                cloakBtn.backgroundColor = .darkGray
            }
        }
    }
    
    @IBAction func onPressedSave(_ sender: Any) {
        guard let user = APPDELEGATE.currentUser else { return }

        let curPassword = currentPasswordField.text
        let newPassword = newPasswordField.text
        let verifyPassword = verifyPasswordField.text
        
        if (curPassword == "") {
            Helper.showMessage(target: self, message: "Please enter current password")
            return
        }
        if (newPassword == "") {
            Helper.showMessage(target: self, message: "Please enter new password")
            return
        }
        if (verifyPassword == "") {
            Helper.showMessage(target: self, message: "Please verify password")
            return
        }
        if (newPassword != verifyPassword){
            Helper.showMessage(target: self, message: "Please enter correctly")
            return
        }
        
        let email = user.email
        let credentials = EmailAuthProvider.credential(withEmail: email, password: curPassword!)
        
        Auth.auth().currentUser?.reauthenticate(with: credentials, completion: { (error) in
            if error != nil{
                Helper.showMessage(target: self, message: (error?.localizedDescription)!)
            }else{
                Auth.auth().currentUser?.updatePassword(to: newPassword!, completion: {(error) in
                    if error != nil{
                        Helper.showMessage(target: self, message: (error?.localizedDescription)!)
                    }else{
                        Helper.showMessage(target: self, message: "Updated successfully")
                    }
                })
            }
        })
    }
    
    @IBAction func onPressedCloak(_ sender: Any) {
        guard let user = APPDELEGATE.currentUser else { return }
        if user.isVisible {
            Helper.confirmMessage(target: self, message: "Are you sure to cloak your account?"){
                FirebaseHelper.setUserDic(dic: [USER_VISIBLE: false])
                APPDELEGATE.currentUser?.isVisible = false
                self.updateCurrentState()
            }
        }else{
            Helper.confirmMessage(target: self, message: "Are you sure to uncloak your account?"){
                FirebaseHelper.setUserDic(dic: [USER_VISIBLE: true])
                APPDELEGATE.currentUser?.isVisible = true
                self.updateCurrentState()
            }
        }
    }
    
    @IBAction func onPressedDelete(_ sender: Any) {
        
        Helper.confirmMessage(target: self, message: "Are you sure to delete your account?"){
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            
            hud.label.text = "Please wait..."

            let uid = APPDELEGATE.currentUser?.uid ?? ""
            
            FirebaseHelper.usersRef.child(uid).removeValue()
            
            FirebaseHelper.userFcmTokensRef.child(uid).removeValue()

            FirebaseHelper.userChannelsRef.child(uid).removeValue()
            
            FirebaseHelper.contactedUsersRef.child(uid).removeValue()
            
            GEOFIRE_USERS.removeKey(uid)

            let userDungeonsRef = FirebaseHelper.userDungeonsRef.child(uid)
            
            userDungeonsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dungeonIds = snapshot.value as? [String: Any]{

                    for (dungeonID, _) in dungeonIds {
                    
                        FirebaseHelper.dungeonsRef.child(dungeonID).removeValue()

                        GEOFIRE_DUNGEONS.removeKey(dungeonID)
                        
                    }

                }

                userDungeonsRef.removeValue()

                Auth.auth().currentUser?.delete(completion: { (error) in
                    
                    hud.hide(animated: true)
                    
                    if let error = error {
                        
                        Helper.showMessage(target: self, message: "Unable to delete the account \n\(error.localizedDescription)")
                        
                    }else{
                        
                        let signinNC = STORYBOARD.instantiateViewController(withIdentifier: "SigninNC")
                        
                        APPDELEGATE.window?.rootViewController = signinNC
                        
                    }
                    
                })
                
            })
            
        }

    }
    
}
