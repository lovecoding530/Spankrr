//
//  MessagesVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/17/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class MessagesVC: UIViewController {
    @IBOutlet weak var chatchannelTableView: UITableView!
    
    var unblockedChannels = [ChatChannel]()
    
    var blockedChannels = [ChatChannel]()

    var onlineUserIDs = [String: Bool]()
    
    let baseVCHelper = BaseVCHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        baseVCHelper.setupNavigationBar(viewController: self)

        chatchannelTableView.delegate = self
        chatchannelTableView.dataSource = self
        
        FirebaseHelper.getUserChatChannelAdded(uid: APPDELEGATE.currentUser?.uid) { (channel) in
            if channel.isBlocked {
                if let existingIndex = self.blockedChannels.index(where: {$0.id == channel.id}) {
                    self.blockedChannels.remove(at: existingIndex)
                }
                self.blockedChannels.append(channel)
                self.blockedChannels.sort{($0.lastMessage?.timestamp)! > ($1.lastMessage?.timestamp)!}
            } else {
                if let existingIndex = self.unblockedChannels.index(where: {$0.id == channel.id}) {
                    self.unblockedChannels.remove(at: existingIndex)
                }
                self.unblockedChannels.append(channel)
                self.unblockedChannels.sort{($0.lastMessage?.timestamp)! > ($1.lastMessage?.timestamp)!}
            }
            self.chatchannelTableView.reloadData()
        }
        
        FirebaseHelper.getOnlineUsers { (onlineUserIDs) in
            self.onlineUserIDs = onlineUserIDs
            self.chatchannelTableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
}

extension MessagesVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if blockedChannels.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Contacted users"
        }else{
            return "Blocked users"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return unblockedChannels.count
        }else{
            return blockedChannels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatChannelTableViewCell", for: indexPath) as! ChatChannelTableViewCell
        
        cell.channel = (indexPath.section == 0) ? unblockedChannels[indexPath.row] : blockedChannels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                let chatVC = ChatVC()
                chatVC.channel = self.unblockedChannels[indexPath.row]
                let chatNavigationController = UINavigationController(rootViewController: chatVC)
                self.present(chatNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
                Helper.confirmMessage(target: self, message: "Are you sure to delete it?"){
                    handler(true)
                    
                    let channel = self.unblockedChannels.remove(at: indexPath.row)
                    
                    let curUserUID = APPDELEGATE.currentUser?.uid ?? ""
                    
                    let channelID = channel.id ?? ""
                    
                    FirebaseHelper.channelsRef.child("\(channelID)/\(CHAT_CHANNEL_USERS)/\(curUserUID)").setValue(false)
                    
                    self.chatchannelTableView.reloadData()
                }
            }
            deleteAction.image = #imageLiteral(resourceName: "Delete")
            deleteAction.backgroundColor = RED_COLOR
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }else{
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            let blockAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
                Helper.confirmMessage(target: self, message: "Are you sure to block?"){
                    handler(true)
                    let curUserUID = APPDELEGATE.currentUser?.uid ?? ""
                    let channel = self.unblockedChannels.remove(at: indexPath.row)
                    FirebaseHelper.userChannelsRef.child("\(curUserUID)/\(channel.id ?? "")").setValue(false)
                }
            }
            blockAction.image = #imageLiteral(resourceName: "block_user")
            blockAction.backgroundColor = RED_COLOR
            
            let configuration = UISwipeActionsConfiguration(actions: [blockAction])
            
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        } else {
            let unblockAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
                Helper.confirmMessage(target: self, message: "Are you sure to unblock?"){
                    handler(true)
                    let curUserUID = APPDELEGATE.currentUser?.uid ?? ""
                    let channel = self.blockedChannels.remove(at: indexPath.row)
                    FirebaseHelper.userChannelsRef.child("\(curUserUID)/\(channel.id ?? "")").setValue(true)
                }
            }
            unblockAction.image = #imageLiteral(resourceName: "unblock_user")
            unblockAction.backgroundColor = RED_COLOR
            
            let configuration = UISwipeActionsConfiguration(actions: [unblockAction])
            
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
}
