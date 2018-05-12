//
//  EditBioVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/19/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class EditBioVC: UIViewController {

    @IBOutlet weak var bioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bioTextView.text = APPDELEGATE.currentUser?.bio
        // Do any additional setup after loading the view.
        
    }

    @IBAction func onPressedSaveBtn(_ sender: Any) {
        let bio = bioTextView.text ?? ""
        if !bio.isEmpty {
            FirebaseHelper.setUserDic(dic: [USER_BIO: bio])
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onPressedBackBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
