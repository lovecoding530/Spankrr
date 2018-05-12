//
//  FindKinkMatchVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/17/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Koloda
import MBProgressHUD

class FindKinkMatchVC: UIViewController {

    @IBOutlet weak var cardViewBtn: UIButton!
    @IBOutlet weak var listViewBtn: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var runoutView: UIView!
    
    var cardUsers = [User]()
    var listUsers = [User]()
    
    let baseVCHelper = BaseVCHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        baseVCHelper.setupNavigationBar(viewController: self)

        // Do any additional setup after loading the view.
        
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self

        let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        pHud.label.text = "Please wait..."
        FirebaseHelper.getAllUsers { (users) in
            pHud.hide(animated: true)
            if users.isEmpty {
                self.runoutView.isHidden = false
            }
            let visibleUsers = users.filter({$0.isVisible})
            self.cardUsers = visibleUsers
            self.listUsers = visibleUsers
            self.kolodaView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func gotoProfile(user: User) {
        let publicProfileVC = STORYBOARD.instantiateViewController(withIdentifier: "PublicProfileVC") as! PublicProfileVC
        publicProfileVC.user = user
        present(publicProfileVC, animated: true, completion: nil)
    }

    // MARK: - IBActions
    @IBAction func onPressedCardView(_ sender: Any) {
        cardViewBtn.isSelected = true
        listViewBtn.isSelected = false
        cardView.isHidden = false
        listView.isHidden = true
    }
    @IBAction func onPressedListView(_ sender: Any) {
        cardViewBtn.isSelected = false
        listViewBtn.isSelected = true
        cardView.isHidden = true
        listView.isHidden = false
    }
}

extension FindKinkMatchVC: KolodaViewDelegate, KolodaViewDataSource {
    //DateSource
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let kinkCardView = KinkCardView(frame: koloda.frame)
        kinkCardView.setUserData(user: cardUsers[index])
        return kinkCardView
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return cardUsers.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return KinkCardOverlayView(frame: koloda.frame)
    }

    //Delegate
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        self.runoutView.isHidden = false
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        gotoProfile(user: cardUsers[index])
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .left {
            let user = cardUsers[index]
            FirebaseHelper.isContactedUser(uid: user.uid ?? "") { (channelID) in
                if channelID == nil {
                    _ = FirebaseHelper.newChatChannelByCurrentUser(otherUserIds: [user.uid])
                }
            }
        }
    }
}

extension FindKinkMatchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KinkTableViewCell", for: indexPath) as! KinkTableViewCell
        cell.setUserData(user: listUsers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let yesAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            let user = self.listUsers[indexPath.row]
            _ = FirebaseHelper.newChatChannelByCurrentUser(otherUserIds: [user.uid])
            self.listUsers.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        yesAction.image = #imageLiteral(resourceName: "yes")
        yesAction.backgroundColor = LIGHT_GREEN
        let configuration = UISwipeActionsConfiguration(actions: [yesAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let noAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            self.listUsers.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        noAction.image = #imageLiteral(resourceName: "no")
        noAction.backgroundColor = RED_COLOR
        let configuration = UISwipeActionsConfiguration(actions: [noAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gotoProfile(user: listUsers[indexPath.row])
    }
}
