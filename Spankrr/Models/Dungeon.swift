//
//  Dungeon.swift
//  Spankrr
//
//  Created by Kangtle on 1/28/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation
import CoreLocation


struct Dungeon {
    
    var id: String
    var name: String
    var description: String
    var location: CLLocationCoordinate2D
    var address: String
    var score: Score
    var photoUrl: String
    var photos: [String]
    var ownerId: String
    var reviewCount: Int
    var featured: Bool
    var lastPaidTimestamp: Int64
    
    init(dic: [String: Any], dungeonID: String) {
        id = dungeonID
        name = dic[DUNGEON_NAME] as? String ?? ""
        description = dic[DUNGEON_DESCRIPTION] as? String ?? ""
        address = dic[DUNGEON_ADDRESS] as? String ?? ""
        photoUrl = dic[DUNGEON_PIC_URL] as? String ?? ""
        
        let locationDic = dic[DUNGEON_LOCATION] as? [String: Any] ?? [:]
        let latitude =  locationDic["lat"] as? Double ?? 0.0
        let longitude = locationDic["long"] as? Double ?? 0.0
        location =      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let scoreDic = dic[SCORE] as? [String: Any] ?? [:]
        score = Score.init(dic: scoreDic)
        
        photos = dic[DUNGEON_PHOTOS] as? [String] ?? []
        ownerId = dic[DUNGEON_OWNER_ID] as! String
        
        reviewCount = dic[DUNGEON_REVIEW_COUNT] as? Int ?? 0
        featured = dic[DUNGEON_FEATURED] as? Bool ?? false
        lastPaidTimestamp = dic[DUNGEON_LAST_PAID_TIME] as? Int64 ?? 0
    }
    
    func shouldPurchaseMonthlyFee() -> Bool{
        if featured {
            let lastPaidTime = lastPaidTimestamp
            let currentTime = Int64(Date().timeIntervalSince1970)
            if Int64(currentTime - lastPaidTime) > MONTH {
                return true
            }
        }
        return false
    }
}
