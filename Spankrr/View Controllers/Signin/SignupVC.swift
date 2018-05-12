//
//  SignupVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/16/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase

class SignupVC: UIViewController {

    // MARK - IBOutlet
    @IBOutlet weak var emailField: UnderLineTextField!
    @IBOutlet weak var passwordField: PasswordTextField!
    @IBOutlet weak var birthdayField: UnderLineTextField!
    @IBOutlet weak var ageYesCheckbox: Checkbox!
    @IBOutlet weak var ageNoCheckbox: Checkbox!
    @IBOutlet weak var createBtn: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        birthdayField.setAsDateField()
        ageYesCheckbox.onSelectStateChanged = {(checkbox, selected) in
            self.ageNoCheckbox.isChecked = !selected
            if selected {
                self.createBtn.isHidden = false
                self.errorView.isHidden = true
                self.titleLabel.text = "Sign up"
                self.titleLabel.textColor = .white
            }else{
                self.createBtn.isHidden = true
                self.errorView.isHidden = false
                self.titleLabel.text = "Access Denied"
                self.titleLabel.textColor = RED_COLOR
            }
        }

        ageNoCheckbox.onSelectStateChanged = {(checkbox, selected) in
            self.ageYesCheckbox.isChecked = !selected
        }
        
        ageYesCheckbox.isChecked = true
        
    }

    // MARK: - IBAction
    @IBAction func onPressedCreateAcount(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let birthday = birthdayField.text ?? ""
        
        if !Helper.isValidEmail(email: email) {
            Helper.showMessage(target: self, message: "Enter your email correctly")
            return
        }
        
        if password.isEmpty {
            Helper.showMessage(target: self, message: "Enter password")
            return
        }
        
        if birthday.isEmpty {
            Helper.showMessage(target: self, message: "Enter your date of birth")
            return
        }
        
        let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        pHud.label.text = "Please wait..."
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            pHud.hide(animated: true)
            if error == nil {
                let uid = user?.uid ?? ""
                let userDic = [
                    USER_ID: uid,
                    USER_EMAIL: email,
                    USER_PASSWORD: password,
                    USER_BIRTHDAY: birthday,
                    USER_LOOKINGFORS: "2" // Ask me
                ]
                DB_REF.child(USERS).child(uid).setValue(userDic)
                self.navigationController?.popViewController(animated: true)
            }else{
                Helper.showMessage(target: self, message: (error?.localizedDescription)!)
            }
        }
    }
    
    @IBAction func onPressedBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
