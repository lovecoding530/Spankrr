//
//  KinkCardOverlayView.swift
//  Spankrr
//
//  Created by Kangtle on 1/22/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Koloda

class KinkCardOverlayView:  OverlayView{
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        componentInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        componentInit()
    }
    
    func componentInit() {
        Bundle.main.loadNibNamed("KinkCardOverlayView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                imageView.image = #imageLiteral(resourceName: "overlay_yes").withRenderingMode(.alwaysTemplate)
                imageView.tintColor = LIGHT_GREEN
            case .right? :
                imageView.image = #imageLiteral(resourceName: "overlay_no")
            default:
                imageView.image = nil
            }
        }
    }
}
