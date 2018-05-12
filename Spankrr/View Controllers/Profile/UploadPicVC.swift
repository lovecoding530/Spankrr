//
//  UploadPicVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/19/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import CropViewController
import MBProgressHUD

class UploadPicVC: UIViewController {

    @IBOutlet weak var picImageView: UIImageView!
    @IBOutlet weak var changePicBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picImageView.makeCircularView()
        
        let picURL = APPDELEGATE.currentUser?.pictureUrl ?? ""
        if !picURL.isEmpty {
            picImageView.layer.borderWidth = 4
            let picRef = STORAGE_REF.child(picURL)
            picImageView.sd_setImage(with: picRef)
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func onPressedSaveBtn(_ sender: Any) {
        let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        pHud.label.text = "Please wait..."

        let uid = APPDELEGATE.currentUser?.uid ?? ""
        let picture = picImageView.image
        let uploadUrl = "images/users/\(uid)_\(Int64(Date().timeIntervalSince1970)).JPG"
        let imagesRef = STORAGE_REF.child(uploadUrl)
        _ = imagesRef.putData(UIImageJPEGRepresentation(picture!, 0.1)!, metadata: nil) { (metadata, error) in
            pHud.hide(animated: true)
            if error == nil {
                FirebaseHelper.setUserDic(dic: [USER_PIC_URL: uploadUrl])
                self.dismiss(animated: true, completion: nil)
            }else{
                Helper.showMessage(target: self, message: "Can't upload picture")
            }
        }

    }
    
    @IBAction func onPressedPicImageView(_ sender: Any){
        Helper.selectImageSource(viewController: self, isVideo: false)
    }

    @IBAction func onPressedChangeBtn(_ sender: Any){
        Helper.selectImageSource(viewController: self, isVideo: false)
    }

    @IBAction func onPressedBackBtn(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UploadPicVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picImageView.image = image
        }
        picker.dismiss(animated: true) {
            let cropViewController = CropViewController.init(croppingStyle: .circular, image: self.picImageView.image!)
            cropViewController.toolbar.doneTextButton.setTitleColor(RED_COLOR, for: .normal)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
}

extension UploadPicVC: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        picImageView.image = image
        picImageView.layer.borderWidth = 4
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    
}
