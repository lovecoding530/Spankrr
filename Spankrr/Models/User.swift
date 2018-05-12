//
//  User.swift
//  Spankrr
//
//  Created by Kangtle on 1/19/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation
import CoreLocation

class User {
    var uid: String!
    var email: String
    var password: String
    var name: String
    var bio: String
    var fetishes = [String]()
    var customFetishes = [String]()
    var fetishesStr: String
    var lookingfors = [Int]()
    var lookingforsStr: String
    var location: CLLocationCoordinate2D
    var address: String
    var pictureUrl: String
    var isVisible: Bool
    
    init(dic: [String: Any], userId: String) {
        uid =           userId
        email =         dic[USER_EMAIL] as? String ?? ""
        password =      dic[USER_PASSWORD] as? String ?? ""
        name =          dic[USER_NAME] as? String ?? ""
        bio =           dic[USER_BIO] as? String ?? ""
        fetishesStr =   dic[USER_FETISHES] as? String ?? ""
        lookingforsStr = dic[USER_LOOKINGFORS] as? String ?? ""
        pictureUrl =    dic[USER_PIC_URL] as? String ?? ""
        address =       dic[USER_ADDRESS] as? String ?? ""
        isVisible =     dic[USER_VISIBLE] as? Bool ?? true

        let locationDic = dic[USER_LOCATION] as? [String: Any] ?? [:]
        let latitude =  locationDic["lat"] as? Double ?? 0.0
        let longitude = locationDic["long"] as? Double ?? 0.0
        location =      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if !fetishesStr.isEmpty {
            let fetisheCompoents = fetishesStr.components(separatedBy: "\n")
            fetishes = fetisheCompoents[0].components(separatedBy: ", ")
            if fetisheCompoents.count > 1 {
                customFetishes = fetisheCompoents[1].components(separatedBy: ", ")
            }
        }
        if !lookingforsStr.isEmpty {
            lookingfors = lookingforsStr.components(separatedBy: ", ").map{Int($0)!}
        }
    }
}
