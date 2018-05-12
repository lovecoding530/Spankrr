//
//  ListMyDungeonsVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/17/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase
import FirebaseStorageUI

class ListMyDungeonsVC: UIViewController {

    @IBOutlet weak var noDungeonsView: UIView!
    @IBOutlet weak var dungeonsView: UIView!
    @IBOutlet weak var dungeonsTableView: UITableView!
    
    var dungeons = [Dungeon]()
    
    let baseVCHelper = BaseVCHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        baseVCHelper.setupNavigationBar(viewController: self)

        dungeonsTableView.delegate = self
        dungeonsTableView.dataSource = self
        
        getMyDungeons()
    }

    func getMyDungeons() {
        
        let uid = APPDELEGATE.currentUser?.uid ?? ""
        
        FirebaseHelper.userDungeonsRef.child(uid).observe(.childAdded, with: { snapshot in
            
            let dungeonID = snapshot.key
            
            FirebaseHelper.dungeonsRef.child(dungeonID).observe(.value, with: {snapshot in

                if let dungeonDic = snapshot.value as? [String : Any] {
                    if let exstingIndex = self.dungeons.index(where: {$0.id == dungeonID}) {
                        self.dungeons.remove(at: exstingIndex)
                    }
                    let dungeon = Dungeon(dic: dungeonDic, dungeonID: dungeonID)
                    self.dungeons.append(dungeon)
                    self.dungeonsTableView.reloadData()

                    if dungeon.shouldPurchaseMonthlyFee(){
                        FirebaseHelper.dungeonsRef.child(dungeon.id).updateChildValues([DUNGEON_FEATURED: false])

                        let featureVC = STORYBOARD.instantiateViewController(withIdentifier: "FeatureDungeonVC") as! FeatureDungeonVC
                        featureVC.dungeon = dungeon
                        self.present(featureVC, animated: true, completion: nil)
                    }
                }
            })
        })
    }
    
    @IBAction func onPressedAdd(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListMyDungeonsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dungeons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DungeonTableViewCell", for: indexPath) as! DungeonTableViewCell
        cell.dungeon = dungeons[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = STORYBOARD.instantiateViewController(withIdentifier: "EditDungeonVC") as! EditDungeonVC
        editVC.editingDungeon = self.dungeons[indexPath.row]
        self.present(editVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            Helper.confirmMessage(target: self, message: "Are you sure to delete the dungeon?"){
                handler(true)

                let dungeon = self.dungeons[indexPath.row]
                FirebaseHelper.dungeonsRef.child(dungeon.id).removeValue()
                FirebaseHelper.userDungeonsRef.child(APPDELEGATE.currentUser?.uid ?? "").child(dungeon.id).removeValue()
                FirebaseHelper.dungeonReviewsRef.child(dungeon.id).removeValue()
                GEOFIRE_DUNGEONS.removeKey(dungeon.id)

                self.dungeons.remove(at: indexPath.row)
                self.dungeonsTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        deleteAction.image = #imageLiteral(resourceName: "Delete")
        deleteAction.backgroundColor = RED_COLOR
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let featureAction = UIContextualAction(style: .normal, title: nil) { (action, view, handler) in
            let featureVC = STORYBOARD.instantiateViewController(withIdentifier: "FeatureDungeonVC") as! FeatureDungeonVC
            featureVC.dungeon = self.dungeons[indexPath.row]
            self.present(featureVC, animated: true, completion: nil)
        }
        featureAction.image = #imageLiteral(resourceName: "lace_on_transparent")
        featureAction.backgroundColor = RED_COLOR
        
        let configuration = UISwipeActionsConfiguration(actions: [featureAction])
        
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
