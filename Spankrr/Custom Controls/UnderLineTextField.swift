//
//  UnderLineTextField.swift
//  Spankrr
//
//  Created by Kangtle on 1/15/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class UnderLineTextField: UITextField {

    override func draw(_ rect: CGRect) {
        attributedPlaceholder = NSAttributedString(string: placeholder!,
                                               attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        setBottomBorder()
    }

}
