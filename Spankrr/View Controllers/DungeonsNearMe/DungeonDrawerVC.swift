//
//  DungeonDrawerVC.swift
//  Spankrr
//
//  Created by Kangtle on 2/14/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Pulley
import IQKeyboardManagerSwift

class DungeonDrawerVC: UIViewController {

    @IBOutlet weak var featuredDungeonCollectionView: UICollectionView!
    @IBOutlet weak var dungeonTableView: UITableView!
    @IBOutlet weak var noDungeonImageView: UIImageView!
    
    var dungeons = [Dungeon]() {
        didSet {
            featuredDungeons = dungeons.filter({$0.featured})
            noDungeonImageView.isHidden = featuredDungeons.count > 0
            dungeonTableView.reloadData()
        }
    }
    
    var featuredDungeons = [Dungeon]() {
        didSet{
            featuredDungeonCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDungeonImageView.isHidden = true

        dungeonTableView.delegate = self
        dungeonTableView.dataSource = self
        
        featuredDungeonCollectionView.delegate = self
        featuredDungeonCollectionView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func gotoDungeonView(dungeon: Dungeon) {
        let dungeonViewVC = STORYBOARD.instantiateViewController(withIdentifier: "DungeonViewVC") as! DungeonViewVC
        dungeonViewVC.dungeon = dungeon
        present(dungeonViewVC, animated: true, completion: nil)
    }
}

extension DungeonDrawerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dungeons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DungeonTableViewCell", for: indexPath) as! DungeonTableViewCell
        
        let dungeon = dungeons[indexPath.row]
        
        cell.dungeon = dungeon
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gotoDungeonView(dungeon: dungeons[indexPath.row])
    }
}

extension DungeonDrawerVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.featuredDungeons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DungeonCollectionViewCell", for: indexPath) as! DungeonCollectionViewCell
        cell.dungeon = self.featuredDungeons[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gotoDungeonView(dungeon: featuredDungeons[indexPath.row])
    }
}

extension DungeonDrawerVC: PulleyDrawerViewControllerDelegate{
    func collapsedDrawerHeight() -> CGFloat {
        return 48
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        return view.frame.width * CGFloat(0.8)
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        if drawer.drawerPosition != .open
        {
        }
    }
}
