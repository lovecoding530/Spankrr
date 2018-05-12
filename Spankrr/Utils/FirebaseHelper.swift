//
//  FirebaseHelper.swift
//  Spankrr
//
//  Created by Kangtle on 1/18/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorageUI

class FirebaseHelper {
    
    static var helper: FirebaseHelper? = nil
    
    static var usersRef = DB_REF.child(USERS)
    static var userFcmTokensRef = DB_REF.child(USER_FCM_TOKENS)
    static var channelsRef = DB_REF.child(CHAT_CHANNELS)
    static var userChannelsRef = DB_REF.child(USER_CHAT_CHANNELS)
    static var messagesRef = DB_REF.child(MESSAGES)
    static var statusRef = DB_REF.child(STATUS)
    static var contactedUsersRef = DB_REF.child(CONTACTED_USERS)
    static var dungeonsRef = DB_REF.child(DUNGEONS)
    static var userDungeonsRef = DB_REF.child(USER_DUNGEONS)
    static var dungeonReviewsRef = DB_REF.child(DUNGEON_REVIEWS)
    static var onlineRef = DB_REF.child(".info/connected")

    static var onlineUserIDs = [String: Bool]()

    static func interface() -> FirebaseHelper {
        if (helper == nil){
            helper = FirebaseHelper()
        }
        return helper!
    }
    
    static func setUserDic(dic: Dictionary<String, Any>) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        DB_REF.child("\(USERS)/\(uid)").updateChildValues(dic)
    }
    
    static func getUserBy(uid: String, callback: ((User?) -> ())!){
        DB_REF.child("\(USERS)/\(uid)").observe(.value, with: {(snapshot) in
            let userDic = snapshot.value as? [String: Any]
            if userDic != nil {
                callback(User.init(dic: userDic!, userId: uid))
            }else{
                callback(nil)
            }
        })
    }
    
    static func getAllUsers(callback: (([User]) -> ())!){
        let uid = Auth.auth().currentUser?.uid ?? ""
        DB_REF.child(USERS).observeSingleEvent(of: .value, with: {(snapshot) in
            let usersDic = snapshot.value as? [String: Any] ?? [:]
            var users = [User]()
            for (key, userDic) in usersDic {
                if key != uid{
                    users.append(User.init(dic: userDic as! [String : Any], userId: key))
                }
            }
            callback(users)
        })
    }
    
    static func getUserChatChannelAdded (uid: String!, callback: @escaping ((ChatChannel) -> ())){

        let userId: String = uid
        
        userChannelsRef.child(userId).observe(.childAdded, with: { (snapshot) in
        
            let channelID = snapshot.key
            
            userChannelsRef.child("\(userId)/\(channelID)").observe(.value, with: { (snapshot) in
                
                let isBlocked = !(snapshot.value as! Bool)

                channelsRef.child(channelID).removeAllObservers()
                channelsRef.child(channelID).observe(.value, with: { (snapshot) in
                    
                    if let channelDic = snapshot.value as? [String: Any] {
                        
                        var channel = ChatChannel()
                        
                        channel.id = channelID
                        
                        channel.name = channelDic[CHAT_CHANNEL_NAME] as? String ?? ""
                        
                        channel.isBlocked = isBlocked
                        
                        guard let lastMessageDic = channelDic[CHAT_CHANNEL_LAST_MESSAGE] as? [String: Any] else { return }
                        
                        channel.lastMessage = Message(dic: lastMessageDic)
                        
                        if let usersDic = channelDic[CHAT_CHANNEL_USERS] as? [String: Any] {
                            
                            let curUserId = APPDELEGATE.currentUser?.uid ?? ""
                            
                            if let visible = usersDic[curUserId] as? Bool, visible == false {
                                
                                return
                                
                            }
                            
                            let group = DispatchGroup()
                            
                            for (uid, _) in usersDic {
                                
                                if curUserId == uid {
                                    
                                    continue
                                    
                                }
                                
                                group.enter()
                                
                                usersRef.child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
                                    
                                    group.leave()
                                    
                                    let userDic = snapshot.value as? [String: Any]
                                    
                                    if userDic != nil {
                                        
                                        let user = User(dic: userDic!, userId: uid)
                                        
                                        channel.users.append(user)
                                        
                                    }else{
                                        
                                        print("not found user", uid)
                                        
                                    }
                                    
                                })
                                
                            }
                            
                            group.notify(queue: .main, execute: {
                                
                                if channel.users.count > 0 {
                                    
                                    callback(channel)
                                    
                                }
                                
                            })
                            
                        } else {
                            
                            callback(channel)
                            
                        }
                        
                    }
                    
                })
                
            })

        })

    }
    
    static func isContactedUser(uid: String, callback: @escaping ((String?) -> ())){
        let curUserId = APPDELEGATE.currentUser?.uid ?? ""
        contactedUsersRef.child("\(curUserId)/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let channelID = snapshot.value as? String {
                callback(channelID)
            }else{
                callback(nil)
            }
        })
    }
    
    static func newChatChannelByCurrentUser(otherUserIds: [String]) -> String? {
        if otherUserIds.count < 1 {
            return nil
        }
        let curUserUID = APPDELEGATE.currentUser?.uid ?? ""
        let curTimeStamp = Int64(Int64(Date().timeIntervalSince1970))
        
        var usersDic = [curUserUID: true]
        for uid in otherUserIds {
            usersDic[uid] = true
        }
        
        let lastMessageDic: [String: Any] = [
            MESSAGE_SENDER_ID: curUserUID,
            MESSAGE_SENDER_NAME: APPDELEGATE.currentUser?.name ?? "",
            MESSAGE_SENDER_PIC_URL: APPDELEGATE.currentUser?.pictureUrl ?? "",
            MESSAGE_CONTENT: FIRST_AUTO_MESSAGE,
            MESSAGE_TYPE: Message.TYPE_STRIING,
            MESSAGE_TIMESTAMP: curTimeStamp
        ]
        let newChannelDic: [String: Any] = [
            CHAT_CHANNEL_LAST_MESSAGE: lastMessageDic,
            CHAT_CHANNEL_USERS: usersDic
        ]
        
        let newChannelRef = channelsRef.childByAutoId()
        newChannelRef.setValue(newChannelDic)

        let newChannelID = newChannelRef.key
        userChannelsRef.child("\(curUserUID)/\(newChannelID)").setValue(true)
        
        for uid in otherUserIds {
            userChannelsRef.child("\(uid)/\(newChannelID)").setValue(true)
        }
        
        messagesRef.child("\(newChannelID)/\(curTimeStamp)").setValue(lastMessageDic)
        
        for uid in otherUserIds {
            contactedUsersRef.child("\(uid)/\(curUserUID)").setValue(newChannelID)
            contactedUsersRef.child("\(curUserUID)/\(uid)").setValue(newChannelID)
        }
        return newChannelID
    }
    
    static func setOnlineStatusListner() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        statusRef.child(uid).setValue(true)
        statusRef.child(uid).onDisconnectRemoveValue()
    }
    
    static func getOnlineUsers(callback: @escaping (([String: Bool]) -> ())){
        statusRef.observe(.value, with: { snapshot in
            onlineUserIDs = snapshot.value as? [String: Bool] ?? [:]
            callback(onlineUserIDs)
        })
    }
}
