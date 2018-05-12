//
//  Score.swift
//  Spankrr
//
//  Created by Kangtle on 2/5/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation

struct Score {
    var avg: Double{
        get{
            return (cleanliness + comfort + location + facilities)/4
        }
    }
    var cleanliness = 0.0
    var comfort = 0.0
    var location = 0.0
    var facilities = 0.0
    
    init(dic: [String: Any]) {
        cleanliness = dic[SCORE_CLEANLINESS] as? Double ?? 0.0
        comfort = dic[SCORE_COMFORT] as? Double ?? 0.0
        location = dic[SCORE_LOCATION] as? Double ?? 0.0
        facilities = dic[SCORE_FACILITIES] as? Double ?? 0.0
    }
}
