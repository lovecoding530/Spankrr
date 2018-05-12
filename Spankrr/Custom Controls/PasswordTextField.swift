//
//  PasswordTextField.swift
//  Spankrr
//
//  Created by Kangtle on 1/15/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class PasswordTextField: UnderLineTextField {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 15))
        button.setImage(UIImage.init(named: "eye"), for: .normal)
        button.center.x = frame.width - 20
        button.center.y = frame.height/2
        button.addTarget(self, action: #selector(onPressedEye), for: .touchUpInside)
        addSubview(button)
        
        self.isSecureTextEntry = true
    }

    func onPressedEye() {
        self.isSecureTextEntry = !self.isSecureTextEntry
    }
}
