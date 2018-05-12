//
//  ChatChannelTableViewCell.swift
//  Spankrr
//
//  Created by Kangtle on 1/23/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class ChatChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var lastMessageTimeLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastSenderImageView: UIImageView!
    @IBOutlet weak var onlineIndicator: UIImageView!
    
    var channel: ChatChannel? {
        didSet {
            let picRef = STORAGE_REF.child((channel?.users.first?.pictureUrl)!)
            channelImageView.sd_setImage(with: picRef, placeholderImage: #imageLiteral(resourceName: "bunnyears"))
            
            if (FirebaseHelper.onlineUserIDs.index(forKey: (channel?.users.first?.uid)!) != nil) {
                onlineIndicator.image = #imageLiteral(resourceName: "Online")
            }else{
                onlineIndicator.image = #imageLiteral(resourceName: "Offline")
            }
            
            channelNameLabel.text = channel?.users.first?.name
            if channel?.lastMessage?.type == Message.TYPE_PHOTO {
                lastMessageLabel.text = "Photo"
            }else if channel?.lastMessage?.type == Message.TYPE_VIDEO {
                lastMessageLabel.text = "Video"
            }else{
                lastMessageLabel.text = channel?.lastMessage?.content
            }

            let lastSenderPicRef = STORAGE_REF.child((channel?.lastMessage?.senderPicUrl)!)
            lastSenderImageView.sd_setImage(with: lastSenderPicRef, placeholderImage: #imageLiteral(resourceName: "bunnyears"))
            
            lastMessageTimeLabel.text = channel?.lastMessage?.timeStr
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        channelImageView.makeCircularView()

        lastSenderImageView.makeCircularView()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
