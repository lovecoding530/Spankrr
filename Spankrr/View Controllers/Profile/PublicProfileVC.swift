//
//  PublicProfileVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/23/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class PublicProfileVC: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var userLookingforView: UIView!
    @IBOutlet weak var userFetishesLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picRef = STORAGE_REF.child(user.pictureUrl)
        userImageView.sd_setImage(with: picRef)
        Helper.insertGradientLayer(target: userImageView)
        
        userNameLabel.text = user.name

        setLocationLabel(location: user.address)
        
        userBioLabel.text = user.bio

        userFetishesLabel.text = user.fetishesStr
        
        var btnIndex = 0
        for view in userLookingforView.subviews {
            let button = view.subviews[0] as! UIButton
            if (user?.lookingfors.contains(btnIndex))! {
                button.isSelected = true
                button.backgroundColor = RED_COLOR
            }
            btnIndex = btnIndex + 1
        }
        
        backBtn.backgroundColor = BACKGROUND_COLOR_3
        backBtn.makeCircularView()
        backBtn.defaultShadow()
        
        // Do any additional setup after loading the view.
    }
    
    func setLocationLabel(location: String) {
        let _location = (location.isEmpty) ? "  No Location Set" : location
        let marker = #imageLiteral(resourceName: "Pin").scaleImage(newHeight: userLocationLabel.font.lineHeight)
        userLocationLabel.attributedText = _location.attributedStringWithImage(at: 0, image: marker)
    }

    @IBAction func onPressedYes(_ sender: Any) {
        FirebaseHelper.isContactedUser(uid: user.uid ?? "") { (channelID) in
            if channelID == nil {
                _ = FirebaseHelper.newChatChannelByCurrentUser(otherUserIds: [self.user.uid])
            }
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onPressedNo(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onBack(_ sender: Any) {
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
