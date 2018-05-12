//
//  Helper.swift
//  Spankrr
//
//  Created by Kangtle on 1/16/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class Helper{
    static let defaults = UserDefaults.standard
    
    static func isValidEmail(email:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func showMessage(target: UIViewController, title:String? = nil, message: String, completion: (()->())?=nil){
        
        let _title = title == nil ? "SPANKRR" : title
        
        let alert = UIAlertController(title: _title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            if(completion != nil){
                completion!()
            }
        }
        alert.addAction(okAction)
        target.present(alert, animated: true, completion: nil)
    }
    
    static func confirmMessage(target: UIViewController, title:String? = nil, message: String, confirmAction: @escaping (()->())){
        
        let _title = title == nil ? "SPANKRR" : title
        
        let alert = UIAlertController(title: _title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            confirmAction()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)

        alert.addAction(okAction)
        alert.addAction(cancelAction)

        target.present(alert, animated: true, completion: nil)
    }
    
    static func selectImageSource(
        viewController: UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate,
        isVideo: Bool)
    {
        struct Holder {
            static var imagePicker = UIImagePickerController()
        }
        Holder.imagePicker.delegate = viewController
        
        //1
        let optionMenu = UIAlertController(title: nil, message: "Open with", preferredStyle: .actionSheet)
        
        // 2
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            Holder.imagePicker.allowsEditing = false
            Holder.imagePicker.sourceType = .photoLibrary
            if isVideo {
                Holder.imagePicker.mediaTypes = [String(kUTTypeMovie)]
            }else{
                Holder.imagePicker.mediaTypes = [String(kUTTypeImage)]
            }
            viewController.present(Holder.imagePicker, animated: true, completion: nil)
            
        })
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if(UIImagePickerController.isSourceTypeAvailable(.camera)){
                Holder.imagePicker.allowsEditing = false
                Holder.imagePicker.sourceType = .camera
                if isVideo {
                    Holder.imagePicker.mediaTypes = [String(kUTTypeMovie)]
                }else{
                    Holder.imagePicker.mediaTypes = [String(kUTTypeImage)]
                }
                viewController.present(Holder.imagePicker, animated: true, completion: nil)
            }else{
                showMessage(target: viewController, message: "This device is no camera")
            }
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        viewController.present(optionMenu, animated: true, completion: nil)
    }
    
    static func insertGradientLayer(target: UIView){
        
        var gl:CAGradientLayer!
        
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.init(rgb: 0x2D2E40).cgColor // 0x1d1d27
        
        gl = CAGradientLayer()
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.5, 1.0]
        
        target.backgroundColor = UIColor.clear
        gl.frame = target.bounds
        target.layer.insertSublayer(gl, at: 0)
    }
    
    static func timeStr(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a, d MMM"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        var timeStr = ""
        
        let diff = Int64(Date().timeIntervalSince1970) - Int64(date.timeIntervalSince1970)
        
        if diff < 2 * 60 {//2min
            timeStr = "Just now"
        }else if diff < 60 * 60 { //1h
            timeStr = "\(Int(diff / 60))min ago"
        }else if diff < 12 * 60 * 60 { //12
            timeStr = "\(Int(diff / 3600))h ago"
        }else{
            timeStr = dateFormatter.string(from: date)
        }
        return timeStr
    }
}
