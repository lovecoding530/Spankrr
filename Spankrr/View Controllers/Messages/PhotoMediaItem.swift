//
//  PhotoMediaItem.swift
//  Spankrr
//
//  Created by Kangtle on 2/7/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//
import Foundation
import JSQMessagesViewController
import FirebaseStorage
import FirebaseStorageUI


class PhotoMediaItem: JSQPhotoMediaItem {
    var asyncImageView: UIImageView!
    
    override init(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    init(withRef ref: StorageReference) {
        super.init()
        let size = super.mediaViewDisplaySize()
        appliesMediaViewMaskAsOutgoing = false
        asyncImageView = UIImageView()
        asyncImageView.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        asyncImageView.contentMode = .scaleAspectFit
        asyncImageView.layer.cornerRadius = 10
        asyncImageView.clipsToBounds = true
        asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        
        let activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
        activityIndicator.frame = asyncImageView.frame
        asyncImageView.addSubview(activityIndicator)

        asyncImageView.sd_setImage(with: ref, placeholderImage: #imageLiteral(resourceName: "bunnyears")) {(image, error, _, _) in
//            self.asyncImageView.frame.size.width = size.height * ((image?.size.width)!/(image?.size.height)!)
//            self.asyncImageView.image = image?.scaleImage(newHeight: size.height)
//            self.asyncImageView.sizeToFit()
            activityIndicator.removeFromSuperview()
        }
    }
    
    override func mediaView() -> UIView? {
        return asyncImageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return asyncImageView.frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
