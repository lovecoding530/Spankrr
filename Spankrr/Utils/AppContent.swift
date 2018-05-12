//
//  AppContent.swift
//  Spankrr
//
//  Created by Kangtle on 1/15/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import GeoFire

let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate
let STORYBOARD = UIStoryboard(name: "Main", bundle: nil)
let USERDEFAULTS = UserDefaults.standard
let LOC_MANAGER = CLLocationManager()

//Colors
let BACKGROUND_COLOR_1 = UIColor.init(rgb: 0x1A1A1A)
let BACKGROUND_COLOR_2 = UIColor.init(rgb: 0x202020)
let BACKGROUND_COLOR_3 = UIColor.init(rgb: 0x222222)
let RED_COLOR = UIColor.init(rgb: 0xD0021B)
let LIGHT_GRAY = UIColor.init(rgb: 0xF1F2F6)
let LIGHT_GREEN = UIColor.init(rgb: 0x25A464)
let GREEN = UIColor.init(rgb: 0x286C49)

//Radius near by ...KM
let NEAR_BY_RADIUS = 2000.0

//Firebase
let USERS = "users"
let USER_ID = "user_id"
let USER_EMAIL = "user_email"
let USER_NAME = "user_name"
let USER_PASSWORD = "user_password"
let USER_BIRTHDAY = "user_birthday"
let USER_BIO = "user_bio"
let USER_FETISHES = "user_fetishes"
let USER_LOOKINGFORS = "user_lookingfors"
let USER_PIC_URL = "user_pic_url"
let USER_LOCATION = "user_location"
let USER_ADDRESS = "user_address"
let USER_VISIBLE = "is_visible"

let USER_FCM_TOKENS = "user_fcm_tokens"

let LOCATION_LAT = "lat"
let LOCATION_LONG = "long"

let CHAT_CHANNELS = "chat_channels"
let CHAT_CHANNEL_ID = "channel_id"
let CHAT_CHANNEL_NAME = "channel_name"
let CHAT_CHANNEL_USERS = "channel_users"
let CHAT_CHANNEL_LAST_MESSAGE = "channel_last_message"

let USER_CHAT_CHANNELS = "user_chat_channels"

let MESSAGES = "messages"
let MESSAGE_SENDER_ID = "sender_id"
let MESSAGE_SENDER_NAME = "sender_name"
let MESSAGE_SENDER_PIC_URL = "sender_pic_url"
let MESSAGE_CONTENT = "content"
let MESSAGE_TYPE = "type"
let MESSAGE_TIMESTAMP = "timestamp"
let FIRST_AUTO_MESSAGE = "We Matched This is an auto response, if you want to chat just message here"

let STATUS = "status"

let CONTACTED_USERS = "contacted_users"

let DUNGEONS = "dungeons"
let DUNGEON_ID = "dungeon_id"
let DUNGEON_OWNER_ID = "owner_id"
let DUNGEON_NAME = "dungeon_name"
let DUNGEON_DESCRIPTION = "dungeon_description"
let DUNGEON_LOCATION = "dungeon_location"
let DUNGEON_ADDRESS = "dungeon_address"
let DUNGEON_PIC_URL = "dungeon_pic_url"
let DUNGEON_PHOTOS = "photos"
let DUNGEON_REVIEW_COUNT = "review_count"
let DUNGEON_FEATURED = "featured"
let DUNGEON_LAST_PAID_TIME = "last_paid_time"

let SCORE = "score"
let SCORE_CLEANLINESS = "cleanliness"
let SCORE_COMFORT = "comfort"
let SCORE_LOCATION = "location"
let SCORE_FACILITIES = "facilities"

let USER_DUNGEONS = "user_dungeons"

let DUNGEON_REVIEWS = "dungeon_reviews"
let DUNGEON_REVIEW_ID = "review_id"
let DUNGEON_REVIEW_WRITER_ID = "writer_id"
let DUNGEON_REVIEW_TITLE = "title"
let DUNGEON_REVIEW_ADVANTAGE = "advantage"
let DUNGEON_REVIEW_DISADVANTAGE = "disadvantage"
let DUNGEON_REVIEW_TIME = "timestamp"

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()
let GEOFIRE_DUNGEONS = GeoFire(firebaseRef: DB_REF.child("geo_fire_dungeons"))
let GEOFIRE_USERS = GeoFire(firebaseRef: DB_REF.child("geo_fire_users"))

