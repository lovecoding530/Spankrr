//
//  Payment.swift
//  Urban
//
//  Created by Kangtle on 11/3/17.
//  Copyright © 2017 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import Braintree
import BraintreeDropIn

let toKinizationKey = "sandbox_j45nw6zd_zf7kdynvtvgz33rv"
let paymentURL = URL(string: "https://us-central1-spankrr-1f273.cloudfunctions.net/pay")!

let MONTHLY_PAY = 4.99
let MONTH:Int64 = 30 * 24 * 3600

class Payment: Any {
    
    func shouldPurchaseMonthlyFee(dungeon: Dungeon) -> Bool{
        if dungeon.featured {
            let lastPaidTime = dungeon.lastPaidTimestamp
            let currentTime = Int64(Date().timeIntervalSince1970)
            if Int64(currentTime - lastPaidTime) > MONTH {
                return true
            }
        }
        return false
    }
    
    func updateMonthlyFeeStatus(dungeon: Dungeon){
        let currentTime = Int64(Date().timeIntervalSince1970)
        let updateDic: [String: Any] = [
            DUNGEON_FEATURED: true,
            DUNGEON_LAST_PAID_TIME: currentTime
        ]
        FirebaseHelper.dungeonsRef.child(dungeon.id).updateChildValues(updateDic)
    }
    
    func pay(viewController: UIViewController!, callback: ((Error?, Bool)->Void)!) {
        
        //NEW
        let request =  BTDropInRequest()
        
        let dropIn = BTDropInController(authorization: toKinizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
                callback(error!, false)
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                if let nonce = result.paymentMethod?.nonce {
                    self.sendRequestPaymentToServer(nonce: nonce, amount: MONTHLY_PAY, callback: callback)
                }
            }
            controller.dismiss(animated: true, completion: nil)
        }
        viewController.present(dropIn!, animated: true, completion: nil)
    }
    
    func sendRequestPaymentToServer(nonce: String, amount: Double, callback: ((Error?, Bool)->Void)!) {
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(nonce)&amount=\(amount)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) {(data, response, error) -> Void in
            guard let data = data else {
                print(error!.localizedDescription)
                callback(error!, false)
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
                print("Transaction failed. Please try again.")
                callback(nil, false)
                return
            }
            
            print("Successfully charged. Thanks So Much :)")
            
            callback(nil, true)
            
        }.resume()
    }
}
