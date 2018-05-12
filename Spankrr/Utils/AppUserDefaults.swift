//
//  AppUserDefaults.swift
//  Spankrr
//
//  Created by Kangtle on 1/15/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class AppUserDefaults {

    static let HAS_RUN_BEFORE = "HAS_RUN_BEFORE"
    static let IS_ACCEPTED_TCS = "IS_ACCEPTED_TCS"
    static let IS_REMEMBERED_ME = "IS_REMEMBERED_ME"
    static let FCM_TOKEN = "FCM_TOKEN"

    static func isFirstLunch() -> Bool {
        let isFirstLunch = !USERDEFAULTS.bool(forKey: HAS_RUN_BEFORE)
        if isFirstLunch {
            USERDEFAULTS.set(true, forKey: HAS_RUN_BEFORE)
        }
        return isFirstLunch
    }
    
    static var isAcceptedTCS: Bool {
        get{
            return USERDEFAULTS.bool(forKey: IS_ACCEPTED_TCS)
        }
        set{
            USERDEFAULTS.set(newValue, forKey: IS_ACCEPTED_TCS)
        }
    }

    static var isRememberedMe: Bool {
        get{
            return USERDEFAULTS.bool(forKey: IS_REMEMBERED_ME)
        }
        set{
            USERDEFAULTS.set(newValue, forKey: IS_REMEMBERED_ME)
        }
    }

    static var rememberedUserEmail: String {
        get{
            return USERDEFAULTS.string(forKey: USER_EMAIL) ?? ""
        }
        set{
            USERDEFAULTS.set(newValue, forKey: USER_EMAIL)
        }
    }
    
    static var rememberedUserPassword: String {
        get{
            return USERDEFAULTS.string(forKey: USER_PASSWORD) ?? ""
        }
        set{
            USERDEFAULTS.set(newValue, forKey: USER_PASSWORD)
        }
    }
    static var fcmToken: String? {
        get{
            return USERDEFAULTS.string(forKey: FCM_TOKEN) ?? nil
        }
        set{
            USERDEFAULTS.set(newValue, forKey: FCM_TOKEN)
        }
    }
}
