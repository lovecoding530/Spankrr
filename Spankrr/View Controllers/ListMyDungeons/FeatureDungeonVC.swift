//
//  FeatureDungeonVC.swift
//  Spankrr
//
//  Created by Kangtle on 2/7/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI
import SwiftyStoreKit
import MBProgressHUD

let productID = "com.abbey.Spankrr.featuredfee"

class FeatureDungeonVC: UIViewController {

    @IBOutlet weak var dungeonImageView: UIImageView!
    @IBOutlet weak var dungeonTitleLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var purchaseInfoLabel: UILabel!
    
    var dungeon: Dungeon!
    let payment = Payment()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dungeonImageView.makeCircularView()
        
        let picRef = STORAGE_REF.child(dungeon.photoUrl)
        dungeonImageView.sd_setImage(with: picRef)
        dungeonTitleLabel.text = dungeon.name
        
        if dungeon.featured {
            purchaseButton.backgroundColor = .darkGray
            purchaseButton.setTitle("Purchased", for: .normal)
            purchaseButton.isEnabled = false
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    @IBAction func onPressedPurchaseButton(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Please wait"
        SwiftyStoreKit.retrieveProductsInfo([productID]) { (result) in
            hud.hide(animated: true)
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    switch result {
                    case .success(let purchase):
                        print("Purchase Success: \(purchase.productId)")
                        self.payment.updateMonthlyFeeStatus(dungeon: self.dungeon)
                        self.performSegueToReturnBack()
                    case .error(let error):
                        switch error.code {
                        case .paymentCancelled: break
                        default:
                            Helper.showMessage(target: self, message: error.localizedDescription)
                        }
                    }
                }
            }else{
                Helper.showMessage(target: self, message: (result.error?.localizedDescription)!)
            }
        }
    }
}
