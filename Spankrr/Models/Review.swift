//
//  Review.swift
//  Spankrr
//
//  Created by Kangtle on 2/3/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation

struct Review {
    var id: String
    var writerId: String
    var title: String
    var advantage: String
    var disadvantage: String
    var timestamp: Int64
    var time: Date
    var timeStr: String
    var score: Score
    
    init(dic: [String: Any], reviewID: String) {
        id = reviewID
        writerId = dic[DUNGEON_REVIEW_WRITER_ID] as! String
        title = dic[DUNGEON_REVIEW_TITLE] as! String
        advantage = dic[DUNGEON_REVIEW_ADVANTAGE] as! String
        disadvantage = dic[DUNGEON_REVIEW_DISADVANTAGE] as! String
        timestamp = dic[DUNGEON_REVIEW_TIME] as! Int64
        
        let scoreDic = dic[SCORE] as? [String: Any] ?? [:]
        score = Score.init(dic: scoreDic)
        
        time = Date(timeIntervalSince1970: TimeInterval(timestamp))
        timeStr = Helper.timeStr(for: time)

    }
}
