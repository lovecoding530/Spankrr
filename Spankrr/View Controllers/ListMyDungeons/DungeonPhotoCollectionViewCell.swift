//
//  DungeonPhotoCollectionViewCell.swift
//  Spankrr
//
//  Created by Kangtle on 2/1/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class DungeonPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var photoUrl: String? {
        didSet {
            let photoRef = STORAGE_REF.child(photoUrl!)
            imageView.sd_setImage(with: photoRef)
        }
    }
}
