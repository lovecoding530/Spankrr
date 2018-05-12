//
//  Checkbox.swift
//  Spankrr
//
//  Created by Kangtle on 1/15/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class Checkbox: UIButton {
    
    open var isChecked: Bool = false {
        didSet {
            if super.isSelected != isChecked {
                super.isSelected = isChecked
                if onSelectStateChanged != nil {
                    onSelectStateChanged!(self, isChecked)
                }
            }
        }
    }
    
    open var onSelectStateChanged: ((_ checkbox: Checkbox, _ selected: Bool) -> Void)?

    override func draw(_ rect: CGRect) {
        setBackgroundImage(UIImage.init(named: "check_on"), for: .selected)
        setBackgroundImage(UIImage.init(named: "check_off"), for: .normal)
        addTarget(self, action: #selector(onPressed), for: .touchUpInside)
    }
    
    func onPressed(){
        isChecked = !isChecked
    }
}
