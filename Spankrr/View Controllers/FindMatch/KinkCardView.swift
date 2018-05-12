//
//  KinkCardView.swift
//  Spankrr
//
//  Created by Kangtle on 1/21/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class KinkCardView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userPicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var lookingforView: UIView!
    let lookingforImages = [#imageLiteral(resourceName: "dominatrix-icon"), #imageLiteral(resourceName: "submissive-icon"), #imageLiteral(resourceName: "askme-icon")]
    let lookingforStrings = ["Dominatrix", "Submissive", " Ask Me!! "]
    override init(frame: CGRect) {
        super.init(frame: frame)
        componentInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        componentInit()
    }
    
    func componentInit() {
        Bundle.main.loadNibNamed("KinkCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setUserData(user: User) {
        let picRef = STORAGE_REF.child(user.pictureUrl)
        userPicImageView.sd_setImage(with: picRef)
        if userPicImageView.layer.sublayers == nil {
            userPicImageView.clipsToBounds = true
            Helper.insertGradientLayer(target: userPicImageView)
        }

        userNameLabel.text = user.name
        setLocationLabel(location: user.address)
        userBioLabel.text = user.bio
        
        var index = 0
        let lookingforViewHeight = Int(lookingforView.frame.height)
        for lookingfor in user.lookingfors {

            let imageView = UIImageView(image: lookingforImages[lookingfor])
            imageView.contentMode = .scaleAspectFit
            let width = lookingforViewHeight - 30
            imageView.frame = CGRect(x: index * lookingforViewHeight, y: 0, width: width, height: width)
            lookingforView.addSubview(imageView)
            
            let label = UILabel(frame: CGRect(x: 0, y: width, width: width + 20, height: 15))
            label.center.x = imageView.center.x
            
            label.text = lookingforStrings[index]
            label.textColor = .white
            label.adjustsFontSizeToFitWidth = true
            lookingforView.addSubview(label)
            
            index = index + 1
        }
        lookingforView.frame = CGRect.init(x: 0, y: Int(lookingforView.frame.origin.y),
                                           width: lookingforViewHeight * user.lookingfors.count - 20,
                                           height: lookingforViewHeight)
        lookingforView.center.x = (lookingforView.superview?.center.x)!
    }
    
    func setLocationLabel(location: String) {
        let _location = (location.isEmpty) ? "  No Location Set" : location
        let marker = #imageLiteral(resourceName: "Pin").scaleImage(newHeight: userLocationLabel.font.lineHeight)
        userLocationLabel.attributedText = _location.attributedStringWithImage(at: 0, image: marker)
    }
}
