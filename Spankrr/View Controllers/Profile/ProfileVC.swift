//
//  ProfileVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/17/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase
import FirebaseStorageUI
import CoreLocation
import GoogleMaps

class ProfileVC: UIViewController {
    @IBOutlet weak var nameEditView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var lookingforView: UIView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var fetishesLabel: UILabel!
    
    let baseVCHelper = BaseVCHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseVCHelper.setupNavigationBar(viewController: self)
        // Do any additional setup after loading the view.
        Helper.insertGradientLayer(target: pictureImageView)

        nameEditView.isHidden = true
        nameField.setPlaceholderColor(color: .white)
        
        setLocationLabel(location: "No Location Set")
        if(LOC_MANAGER.location != nil){
            getCurAddress()
        }
        
        let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        pHud.label.text = "Please wait..."
        FirebaseHelper.getUserBy(uid: Auth.auth().currentUser?.uid ?? "") { (user) in
            pHud.hide(animated: true)
            if user != nil {
                APPDELEGATE.currentUser = user
                
                let picRef = STORAGE_REF.child(user?.pictureUrl ?? "")
                self.pictureImageView.sd_setImage(with: picRef)
                
                self.nameField.text = user?.name
                self.setLocationLabel(location: (user?.address.isEmpty)! ? "  No Location Set" : (user?.address)!)
                self.bioLabel.text = user?.bio
                
                var btnIndex = 0
                for view in self.lookingforView.subviews {
                    let button = view.subviews[0] as! UIButton
                    if (user?.lookingfors.contains(btnIndex))! {
                        button.isSelected = true
                        button.backgroundColor = RED_COLOR
                    }
                    btnIndex = btnIndex + 1
                }
                
                self.fetishesLabel.text = user?.fetishesStr
            }else{
                Helper.showMessage(target: self, message: "Can't connect to database")
            }
        }
        
        FirebaseHelper.setOnlineStatusListner()
    }
    
    func getCurAddress() {
        let coordinate = (LOC_MANAGER.location?.coordinate)!

        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            
            guard error == nil else {
                return
            }
            
            if let result = response?.firstResult() {

                let address = "\(result.locality ?? ""), \(result.country ?? "")"
                
                let location = [
                    LOCATION_LAT: coordinate.latitude,
                    LOCATION_LONG: coordinate.longitude
                ]

                FirebaseHelper.setUserDic(dic: [USER_LOCATION: location,
                                                USER_ADDRESS: address])

                let uid = Auth.auth().currentUser?.uid ?? ""

                GEOFIRE_USERS.setLocation(
                    CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude),
                    forKey: uid
                )
            }
        }
    }
    
    func setLocationLabel(location: String) {
        
        let marker = #imageLiteral(resourceName: "Pin").scaleImage(newHeight: locationLabel.font.lineHeight)
        locationLabel.attributedText = location.attributedStringWithImage(at: 0, image: marker)
    }

    // MARK: - IBActions
    @IBAction func onPressedShuffle(_ sender: Any) {
        let badassNames = [
            "Aspect", "Bender", "Big Papa", "Bowser", "Bruise", "Cannon", "Clink", "Cobra", "Colt", "Crank", "Creep", "Daemon", "Decay", "Diablo", "Doom", "Dracula", "Dragon", "Fender", "Fester", "Fisheye", "Flack", "Gargoyle", "Grave", "Gunner", "Hash", "Hashtag", "Indominus", "Ironclad","Kraken", "Lynch", "Mad Dog", "O'Doyle", "Psycho", "Ranger", "Ratchet", "Reaper", "Rigs", "Ripley", "Roadkill", "Ronin", "Rubble", "Sasquatch", "Scar", "Shiver", "Skinner", "Skull Crusher", "Slasher", "Steelshot", "Surge", "Sythe", "Trip", "Trooper", "Tweek", "Vein", "Void", "Wardon", "Killer", "Wraith", "Knuckles", "Zero"
        ]
        
        let hardcoreNames = [
            "Steel", "Kevlar", "Lightning", "Tito", "Bullet-Proof", "Fire-Bred", "Titanium", "Hurricane", "Ironsides", "Iron-Cut", "Tempest", "Iron Heart", "Steel Forge", "Pursuit", "Steel Foil"
        ]
        
        let sickRebelliousNames = [
            "Upsurge", "Uprising", "Overthrow", "Breaker", "Sabotage", "Dissent", "Subversion", "Rebellion", "Insurgent"
        ]
        
        let monsterNames = [
            "Loch", "Golem", "Wendigo", "Rex", "Hydra", "Behemoth", "Balrog", "Manticore", "Gorgon", "Basilisk", "Minotaur", "Leviathan", "Cerberus", "Mothman", "Sylla", "Charybdis", "Orthros", "Baal", "Cyclops", "Satyr", "Azrael"
        ]
        
        let intenseNames = [
            "Ballistic", "Furor", "Uproar", "Fury", "Ire", "Demented", "Wrath", "Madness", "Schizo", "Rage", "Savage", "Manic", "Frenzy", "Mania", "Derange"
        ]
        
        let grittyNames = [
            "V", "Atilla", "Darko", "Terminator", "Conqueror", "Mad Max", "Siddhartha", "Suleiman", "Billy the Butcher", "Thor", "Napoleon", "Maximus", "Khan", "Geronimo", "Leon", "Leonidas", "Dutch", "Cyrus", "Hannibal", "Dux", "Mr. Blonde", "Agrippa", "Jesse James", "Matrix"
        ]
        
        let hittingNames = [
            "Bleed", "X-Skull", "Gut", "Nail", "Jawbone", "Socket", "Fist", "Skeleton", "Footslam", "Tooth", "Craniax", "Head-Knocker", "K-9", "Bone", "Razor", "Kneecap", "Cut", "Slaughter", "Soleus", "Gash", "Scalp", "Blood", "Scab", "Torque"
        ]
        
        let destructionNames = [
            "Wracker", "Annihilator", "Finisher", "Wrecker", "Destroyer", "Overtaker", "Clencher", "Stabber", "Saboteur", "Masher", "Hitter", "Rebel", "Crusher", "Obliterator", "Eliminator", "Slammer", "Exterminator", "Hell-Raiser", "Thrasher", "Ruiner", "Mutant"
        ]
        
        let allNames = [
            badassNames,
            hardcoreNames,
            sickRebelliousNames,
            monsterNames,
            intenseNames,
            grittyNames,
            hittingNames,
            destructionNames
        ]
        
        let typeIndex = Int(arc4random()) % allNames.count

        let names = allNames[typeIndex]
        
        let nameIndex = Int(arc4random()) % names.count
        
        let name = names[nameIndex]
        
        nameField.text = name
    }
    @IBAction func didBeginEditingName(_ sender: Any) {
        nameEditView.isHidden = false
        nameField.textColor = .black
    }
    
    @IBAction func didEndEdingName(_ sender: Any) {
        nameEditView.isHidden = true
        nameField.textColor = .white
    }
    
    @IBAction func onPressedConfirmName(_ sender: Any) {
        nameEditView.isHidden = true
        nameField.textColor = .white
        nameField.endEditing(true)
        
        let name = nameField.text ?? ""
        if !name.isEmpty {
            FirebaseHelper.setUserDic(dic: [USER_NAME: name])
        }
    }
    
    @IBAction func onPressedLookingForBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.backgroundColor = RED_COLOR
        }else{
            sender.backgroundColor = .clear
        }
        
        var selectedLookingfors = [String]()
        var buttonIndex = 0
        for view in lookingforView.subviews {
            let button = view.subviews[0] as! UIButton
            if button.isSelected {
                selectedLookingfors.append(String(buttonIndex))
            }
            buttonIndex = buttonIndex + 1
        }
        let joinedStr = selectedLookingfors.joined(separator: ", ")
        FirebaseHelper.setUserDic(dic: [USER_LOOKINGFORS: joinedStr])
    }
    
    @IBAction func onPressedEditBio(_ sender: Any) {
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
