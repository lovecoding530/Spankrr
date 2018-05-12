//
//  ChatVC.swift
//  Urban
//
//  Created by Kangtle on 8/19/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import IQKeyboardManagerSwift
import Firebase
import FirebaseStorageUI
import MBProgressHUD
import SimpleImageViewer
import MobileCoreServices
import AVFoundation
import AVKit

class ChatVC: JSQMessagesViewController {

    var channel: ChatChannel!
    var messages = [JSQMessage]()

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    
    var avatarTemp: JSQMessagesAvatarImage!
    var avatarBot: JSQMessagesAvatarImage!

    var avatars = [String: JSQMessagesAvatarImage]()
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        initToolbar()
        
        IQKeyboardManager.sharedManager().enable = false
        
        makeAvatars()
        getMessages()

        avatarTemp = JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: #imageLiteral(resourceName: "bunnyears"))
        avatarBot = JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: #imageLiteral(resourceName: "robot"))

        self.view.backgroundColor = LIGHT_GRAY
        self.collectionView?.backgroundColor = .clear

        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.white)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: RED_COLOR.withAlphaComponent(0.9))

        initCollectionView()
    }
    
    func initNavigationBar(){
        self.navigationController?.navigationBar.barTintColor = BACKGROUND_COLOR_2
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = channel.users.first?.name.uppercased()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone))
        doneBtn.tintColor = RED_COLOR
        self.navigationItem.rightBarButtonItem = doneBtn
    }
    
    func initToolbar() {
//        self.inputToolbar.contentView?.leftBarButtonItem = nil //Left Button
        self.inputToolbar.contentView?.rightBarButtonItem?.setTitle("SEND", for: .normal)
        self.inputToolbar.contentView?.rightBarButtonItemWidth = 50.0
        self.inputToolbar.contentView?.rightBarButtonItem?.setTitleColor(RED_COLOR, for: .normal)
    }
    
    func onDone() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initCollectionView(){
        collectionView?.collectionViewLayout.incomingAvatarViewSize =
            CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize =
            CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        
        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false
        automaticallyScrollsToMostRecentMessage = true
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        self.collectionView?.contentInsetAdjustmentBehavior = .never
    }
    
    func makeAvatars(){
        let curUser = APPDELEGATE.currentUser
        let picRef = STORAGE_REF.child((curUser?.pictureUrl)!)
        let downloaderImageView = UIImageView()
        downloaderImageView.sd_setImage(with: picRef, placeholderImage: #imageLiteral(resourceName: "bunnyears")) {(image, error, _, _) in
            self.avatars[(curUser?.uid)!] = JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: downloaderImageView.image!)
        }
        
        for user in channel.users {
            let downloaderImageView = UIImageView()
            let picRef = STORAGE_REF.child(user.pictureUrl)
            downloaderImageView.sd_setImage(with: picRef, placeholderImage: #imageLiteral(resourceName: "bunnyears")) {(image, error, _, _) in
                self.avatars[user.uid] = JSQMessagesAvatarImageFactory().avatarImage(withPlaceholder: downloaderImageView.image!)
            }
        }
    }

    func getMessages(){
        let messageRef = FirebaseHelper.messagesRef.child(channel.id)
        messageRef.observe(.childAdded, with: {(snapshot) in
            let messageDic = snapshot.value as? [String : Any]
            if messageDic != nil {
                let mMessage = Message(dic: messageDic!)
                switch mMessage.type {
                case Message.TYPE_PHOTO:
                    let photoItem = JSQPhotoMediaItem(maskAsOutgoing: mMessage.senderId == self.senderId())
                    let message = JSQMessage.init(senderId: mMessage.senderId, displayName: mMessage.senderName, media: photoItem)
                    self.messages.append(message)

                    let picRef = STORAGE_REF.child(mMessage.content)
                    let downloaderImageView = UIImageView()
                    downloaderImageView.sd_setImage(with: picRef, placeholderImage: nil) {(image, error, _, _) in
                        photoItem.image = image
                        self.finishSendingMessage(animated: true)
                    }
                    break
                case Message.TYPE_VIDEO:
                    let videoItem = JSQVideoMediaItem(maskAsOutgoing: mMessage.senderId == self.senderId())
                    let message = JSQMessage.init(senderId: mMessage.senderId, displayName: mMessage.senderName, media: videoItem)
                    self.messages.append(message)

                    let videoRef = STORAGE_REF.child(mMessage.content)
                    videoRef.downloadURL(completion: { (url, error) in
                        videoItem.fileURL = url
                        self.finishSendingMessage(animated: true)
                    })
                    
                    let thumbRef = STORAGE_REF.child("\(mMessage.content).JPG")
                    let downloaderImageView = UIImageView()
                    downloaderImageView.sd_setImage(with: thumbRef, placeholderImage: nil) {(image, error, _, _) in
                        videoItem.thumbnailImage = image
                        videoItem.isReadyToPlay = true
                        self.finishSendingMessage(animated: true)
                    }

                    break
                default:
                    let message = JSQMessage(senderId: mMessage.senderId, senderDisplayName: "", date: mMessage.time, text: mMessage.content)
                    self.messages.append(message)
                    break
                }
                self.finishSendingMessage(animated: true)
            }
        })
    }
    
    // MARK: JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        let channelId = self.channel.id ?? ""
        let opponentId = channel.users.first?.uid ?? ""
        let opponentChannel = FirebaseHelper.userChannelsRef.child("\(opponentId)/\(channelId)")
        opponentChannel.observeSingleEvent(of: .value, with: { (snapshot) in
            let isBlocked = !(snapshot.value as! Bool)

            if isBlocked {
                Helper.showMessage(target: self, message: "Can't send message\nThe user blocked you")
            }else{
                let curTimeStamp = Int64(date.timeIntervalSince1970)
                let messageDic: [String: Any] = [
                    MESSAGE_SENDER_ID: APPDELEGATE.currentUser?.uid ?? "",
                    MESSAGE_SENDER_NAME: APPDELEGATE.currentUser?.name ?? "",
                    MESSAGE_SENDER_PIC_URL: APPDELEGATE.currentUser?.pictureUrl ?? "",
                    MESSAGE_CONTENT: text,
                    MESSAGE_TYPE: Message.TYPE_STRIING,
                    MESSAGE_TIMESTAMP: curTimeStamp
                ]
                FirebaseHelper.messagesRef.child("\(channelId)/\(curTimeStamp)").setValue(messageDic)
                FirebaseHelper.channelsRef.child("\(channelId)/\(CHAT_CHANNEL_LAST_MESSAGE)").setValue(messageDic)
                for user in self.channel.users {
                    FirebaseHelper.channelsRef.child("\(channelId)/\(CHAT_CHANNEL_USERS)/\(user.uid ?? "")").setValue(true)
                }
            }
        })
    }
    
    override func senderId() -> String {
        return APPDELEGATE.currentUser?.uid ?? ""
    }
    
    override func senderDisplayName() -> String {
        return APPDELEGATE.currentUser?.name ?? ""
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == self.senderId() ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource?
    {
        if let text = messages[indexPath.item].text, text == FIRST_AUTO_MESSAGE {

            return avatarBot
            
        }else{
            
            let messageSenderId = messages[indexPath.item].senderId
            let avatar = avatars[messageSenderId]
            return avatar == nil ? avatarTemp : avatar

        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if shouldShowTopLabel(index: indexPath.item){
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
                                 heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if shouldShowTopLabel(index: indexPath.item){
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        let _cell = cell as! JSQMessagesCollectionViewCell
        if messages[indexPath.item].senderId == self.senderId() {
            if let textView = _cell.textView {
                textView.textColor = UIColor.white
            }
        }
        else {
            if let textView = _cell.textView {
                textView.textColor = UIColor.darkGray
            }
        }
    }
    
    func shouldShowTopLabel(index: Int) -> Bool{
        let preIndex = index - 1 > 0 ? index - 1 : 0
        let prevMessage = self.messages[preIndex]
        let message = self.messages[index]
        let timeDiff = message.date.timeIntervalSince1970 - prevMessage.date.timeIntervalSince1970
        if (index % 10 == 0 || timeDiff > 60 * 60 * 6) {
            return true
        }
        return false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        //1
        let optionMenu = UIAlertController(title: nil, message: "Media Items", preferredStyle: .actionSheet)
        
        // 2
        let photoAction = UIAlertAction(title: "Send Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            Helper.selectImageSource(viewController: self, isVideo: false)
        })
        let videoAction = UIAlertAction(title: "Send Video", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            Helper.selectImageSource(viewController: self, isVideo: true)
        })
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        // 4
        optionMenu.addAction(photoAction)
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(videoAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        let message = self.messages[indexPath.item]
        if message.isMediaMessage {
            let media = message.media
            switch media {
            case is JSQPhotoMediaItem:
                let photoItem = media as! JSQPhotoMediaItem

                let configuration = ImageViewerConfiguration { config in
                    config.imageView = photoItem.mediaView() as? UIImageView
                }
                
                let imageViewerController = ImageViewerController(configuration: configuration)
                
                present(imageViewerController, animated: true)
                break
            case is JSQVideoMediaItem:
                let videoItem = media as! JSQVideoMediaItem

                guard let url = videoItem.fileURL else { return }
                
                let avpController = AVPlayerViewController()
                
                let player = AVPlayer(url: url)
                avpController.player = player
                self.present(avpController, animated: true, completion: nil)

                break
            default:
                break
            }
        }
    }
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker.mediaTypes.first == String(kUTTypeImage) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
                pHud.label.text = "Sending..."
                
                let curTimeStamp = Int64(Date().timeIntervalSince1970)
                
                let uploadUrl = "images/chat/\(channel.id ?? "")_\(curTimeStamp).JPG"
                
                let imageRef = STORAGE_REF.child(uploadUrl)
                _ = imageRef.putData(UIImageJPEGRepresentation(image, 0.1)!, metadata: nil) { (metadata, error) in
                    
                    pHud.hide(animated: true)
                    
                    if error == nil {
                        let messageDic: [String: Any] = [
                            MESSAGE_SENDER_ID: APPDELEGATE.currentUser?.uid ?? "",
                            MESSAGE_SENDER_NAME: APPDELEGATE.currentUser?.name ?? "",
                            MESSAGE_SENDER_PIC_URL: APPDELEGATE.currentUser?.pictureUrl ?? "",
                            MESSAGE_CONTENT: uploadUrl,
                            MESSAGE_TYPE: Message.TYPE_PHOTO,
                            MESSAGE_TIMESTAMP: curTimeStamp
                        ]
                        FirebaseHelper.messagesRef.child("\(self.channel.id ?? "")/\(curTimeStamp)").setValue(messageDic)
                        FirebaseHelper.channelsRef.child("\(self.channel.id ?? "")/\(CHAT_CHANNEL_LAST_MESSAGE)").setValue(messageDic)
                    }else{
                        Helper.showMessage(target: self, message: "Can't upload picture")
                    }
                }
            }
        }else{
            if let url = info[UIImagePickerControllerMediaURL] as? URL {
                let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
                pHud.label.text = "Sending..."
                do {
                    let data = try Data(contentsOf: url)
                    let curTimeStamp = Int64(Date().timeIntervalSince1970)
                    let type = url.pathExtension
                    let uploadUrl = "videos/chat/\(channel.id ?? "")_\(curTimeStamp).\(type)"
                    
                    let thumbImage = VideoHelper.thumbnailFromVideo(videoUrl: url, time: CMTimeMake(0, 1))
                    let thumbUrl = "\(uploadUrl).JPG"

                    let videoRef = STORAGE_REF.child(uploadUrl)
                    videoRef.putData(data, metadata: nil) { (metadata, error) in
                        pHud.hide(animated: true)
                        
                        if error == nil {
                            let messageDic: [String: Any] = [
                                MESSAGE_SENDER_ID: APPDELEGATE.currentUser?.uid ?? "",
                                MESSAGE_SENDER_NAME: APPDELEGATE.currentUser?.name ?? "",
                                MESSAGE_SENDER_PIC_URL: APPDELEGATE.currentUser?.pictureUrl ?? "",
                                MESSAGE_CONTENT: uploadUrl,
                                MESSAGE_TYPE: Message.TYPE_VIDEO,
                                MESSAGE_TIMESTAMP: curTimeStamp
                            ]
                            FirebaseHelper.messagesRef.child("\(self.channel.id ?? "")/\(curTimeStamp)").setValue(messageDic)
                            FirebaseHelper.channelsRef.child("\(self.channel.id ?? "")/\(CHAT_CHANNEL_LAST_MESSAGE)").setValue(messageDic)
                        }else{
                            Helper.showMessage(target: self, message: "Can't upload video")
                        }
                    }
                    
                    let thumbRef = STORAGE_REF.child(thumbUrl)
                    _ = thumbRef.putData(UIImageJPEGRepresentation(thumbImage, 0.1)!, metadata: nil)
                } catch {
                    print("Unable to load data: \(error)")
                    pHud.hide(animated: true)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

