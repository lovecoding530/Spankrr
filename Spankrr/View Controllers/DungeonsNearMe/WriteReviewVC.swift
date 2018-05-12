//
//  WriteReviewVC.swift
//  Spankrr
//
//  Created by Kangtle on 2/3/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class WriteReviewVC: UIViewController {
    @IBOutlet weak var headlineField: UnderLineTextField!
    @IBOutlet weak var advantageField: UITextView!
    @IBOutlet weak var disadvantageField: UITextView!
    
    @IBOutlet weak var cleanlinessScoreLabel: UILabel!
    @IBOutlet weak var comfortScoreLabel: UILabel!
    @IBOutlet weak var locationScoreLabel: UILabel!
    @IBOutlet weak var facilitiesScoreLabel: UILabel!
    
    @IBOutlet weak var cleanlinessSlider: UISlider!
    @IBOutlet weak var comfortSlider: UISlider!
    @IBOutlet weak var locationSlider: UISlider!
    @IBOutlet weak var facilitiesSlider: UISlider!

    var dungeon: Dungeon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClose(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    @IBAction func onDone(_ sender: Any) {
        let uid = APPDELEGATE.currentUser?.uid
        let headline = headlineField.text ?? ""
        let advantage = advantageField.text ?? ""
        let disadvantage = disadvantageField.text ?? ""
        
        if headline.isEmpty {
            Helper.showMessage(target: self, message: "Please enter head line")
            return
        }

        if advantage.isEmpty && disadvantage.isEmpty {
            Helper.showMessage(target: self, message: "Please enter advantage or disadvantage")
            return
        }
        
        let cleanliness = Double(cleanlinessSlider.value)
        let comfort = Double(comfortSlider.value)
        let location = Double(locationSlider.value)
        let facilities = Double(facilitiesSlider.value)

        if cleanliness == 0.0 && comfort == 0.0 && location == 0.0 && facilities == 0.0 {
            Helper.showMessage(target: self, message: "Please provide at least one score")
            return
        }
        
        let reviewDic: [String: Any] = [
            DUNGEON_REVIEW_WRITER_ID: uid!,
            DUNGEON_REVIEW_TITLE: headline,
            DUNGEON_REVIEW_ADVANTAGE: advantage,
            DUNGEON_REVIEW_DISADVANTAGE: disadvantage,
            DUNGEON_REVIEW_TIME: Int64(Date().timeIntervalSince1970),
            SCORE: [
                SCORE_CLEANLINESS: cleanliness,
                SCORE_COMFORT: comfort,
                SCORE_LOCATION: location,
                SCORE_FACILITIES: facilities
            ]
        ]
        
        let reviewCount = dungeon.reviewCount + 1
        let avgCleanliness = (dungeon.score.cleanliness + cleanliness)/Double(reviewCount)
        let avgComfort = (dungeon.score.comfort + comfort)/Double(reviewCount)
        let avgLocation = (dungeon.score.location + location)/Double(reviewCount)
        let avgFacilities = (dungeon.score.facilities + facilities)/Double(reviewCount)

        let dungeonUpdateDic: [String: Any] = [
            DUNGEON_REVIEW_COUNT: reviewCount,
            SCORE: [
                SCORE_CLEANLINESS: avgCleanliness,
                SCORE_COMFORT: avgComfort,
                SCORE_LOCATION: avgLocation,
                SCORE_FACILITIES: avgFacilities
            ]
        ]
        
        FirebaseHelper.dungeonReviewsRef.child(dungeon.id).childByAutoId().setValue(reviewDic)
        FirebaseHelper.dungeonsRef.child(dungeon.id).updateChildValues(dungeonUpdateDic)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onValueChangedCleanliness(_ sender: UISlider) {
        cleanlinessScoreLabel.text = sender.value.format(f: ".1")
    }
    
    @IBAction func onValueChangedComfort(_ sender: UISlider) {
        comfortScoreLabel.text = sender.value.format(f: ".1")
    }
    
    @IBAction func onValueChangedLocation(_ sender: UISlider) {
        locationScoreLabel.text = sender.value.format(f: ".1")
    }
    
    @IBAction func onValueChangedFacilities(_ sender: UISlider) {
        facilitiesScoreLabel.text = sender.value.format(f: ".1")
    }

}
