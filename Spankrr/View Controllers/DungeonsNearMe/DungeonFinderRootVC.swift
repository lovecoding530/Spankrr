//
//  DungeonFinderRootVC.swift
//  Spankrr
//
//  Created by Kangtle on 2/14/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Pulley

class DungeonFinderRootVC: PulleyViewController {

    let baseVCHelper = BaseVCHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        baseVCHelper.setupNavigationBar(viewController: self)

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

        drawerBackgroundVisualEffectView = visualEffectView
        
        setDrawerPosition(position: .partiallyRevealed)
        // Do any additional setup after loading the view.
    }
}
