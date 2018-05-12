//
//  KinkTableViewCell.swift
//  Spankrr
//
//  Created by Kangtle on 1/23/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class KinkTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.makeCircularView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUserData(user: User) {
        let picRef = STORAGE_REF.child(user.pictureUrl)
        userImageView.sd_setImage(with: picRef, placeholderImage: #imageLiteral(resourceName: "bunnyears"))
        
        userNameLabel.text = user.name
        setLocationLabel(location: user.address)
        userBioLabel.text = user.bio
//        userBioLabel.sizeToFit()
    }
    
    func setLocationLabel(location: String) {
        let _location = (location.isEmpty) ? "  No Location Set" : location
        let marker = #imageLiteral(resourceName: "Pin").scaleImage(newHeight: userLocationLabel.font.lineHeight)
        userLocationLabel.attributedText = _location.attributedStringWithImage(at: 0, image: marker)
    }
}
