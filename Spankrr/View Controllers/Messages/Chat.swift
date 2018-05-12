//
//  ChatChannel.swift
//  Spankrr
//
//  Created by Kangtle on 1/23/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation

struct Message {
    static let TYPE_STRIING = "string"
    static let TYPE_PHOTO = "photo"
    static let TYPE_LOCATION = "location"
    static let TYPE_VIDEO = "video"
    static let TYPE_AUDIO = "audio"

    var senderId: String
    var senderName: String
    var senderPicUrl: String
    var sender: User?
    var content: String
    var type: String
    var timestamp: Int64
    var time: Date
    var timeStr: String
    
    init(dic: [String: Any]) {
        senderId = dic[MESSAGE_SENDER_ID] as? String ?? ""
        senderName = dic[MESSAGE_SENDER_NAME] as? String ?? ""
        senderPicUrl = dic[MESSAGE_SENDER_PIC_URL] as? String ?? ""
        content = dic[MESSAGE_CONTENT] as? String ?? ""
        type = dic[MESSAGE_TYPE] as? String ?? ""
        timestamp = dic[MESSAGE_TIMESTAMP] as? Int64 ?? Int64(Date().timeIntervalSince1970)
        time = Date(timeIntervalSince1970: TimeInterval(timestamp))
        timeStr = Helper.timeStr(for: time)
    }
}

struct ChatChannel {
    var id: String!
    var name = ""
    var users = [User]()
    var lastMessage: Message? = nil
    var isBlocked = false
}

