//
//  SigninVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/16/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase

class SigninVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var emailField: UnderLineTextField!
    @IBOutlet weak var passwordField: PasswordTextField!
    @IBOutlet weak var remembermeCheckbox: Checkbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppUserDefaults.isRememberedMe {
            emailField.text = AppUserDefaults.rememberedUserEmail
            passwordField.text = AppUserDefaults.rememberedUserPassword
            remembermeCheckbox.isChecked = AppUserDefaults.isRememberedMe
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IBAction
    @IBAction func onPressedLogin(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        if !Helper.isValidEmail(email: email) {
            Helper.showMessage(target: self, message: "Enter your email correctly")
            return
        }
        
        if password.isEmpty {
            Helper.showMessage(target: self, message: "Enter password")
            return
        }

        let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        pHud.label.text = "Please wait..."
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            pHud.hide(animated: true)
            if let user = user {
                let isRememberMe = self.remembermeCheckbox.isChecked
                AppUserDefaults.isRememberedMe = isRememberMe
                if isRememberMe {
                    AppUserDefaults.rememberedUserEmail = email
                    AppUserDefaults.rememberedUserPassword = password
                }
                
                if let fcmToken = AppUserDefaults.fcmToken {
                    FirebaseHelper.userFcmTokensRef.child("\(user.uid)/\(fcmToken)").setValue(0)
                }

                let profileVC = STORYBOARD.instantiateViewController(withIdentifier: "ProfileVC")
                
                APPDELEGATE.window?.rootViewController = UINavigationController.init(rootViewController: profileVC)
            }else{
                Helper.showMessage(target: self, message: (error?.localizedDescription)!)
            }
        }
    }
    
    @IBAction func onPressedForgotPassword(_ sender: Any) {
        let email = emailField.text ?? ""
        
        if !Helper.isValidEmail(email: email) {
            Helper.showMessage(target: self, message: "Enter your email correctly")
            return
        }

        let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        pHud.label.text = "Please wait..."
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            pHud.hide(animated: true)
            if error == nil {
                Helper.showMessage(target: self, message: "Just sent a password reset email")
            }else{
                Helper.showMessage(target: self, message: (error?.localizedDescription)!)
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
