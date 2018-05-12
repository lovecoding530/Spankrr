//
//  Slider.swift
//  Spankrr
//
//  Created by Kangtle on 2/4/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class Slider: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 4
        return newBounds
    }
    
    override func draw(_ rect: CGRect) {
        if thumbTintColor != .clear {
            setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .normal)
            setThumbImage(#imageLiteral(resourceName: "slider_thumb"), for: .highlighted)
        }else{
            setThumbImage(UIImage(), for: .normal)
            setThumbImage(UIImage(), for: .highlighted)
            isUserInteractionEnabled = false
        }
    }
}
