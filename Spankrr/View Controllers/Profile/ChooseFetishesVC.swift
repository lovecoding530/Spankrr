//
//  ChooseFetishesVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/19/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import TagListView

class ChooseFetishesVC: UIViewController {

    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var customTagListView: TagListView!
    @IBOutlet weak var customTagField: UITextField!
    
    let tags = [
        "bruises",
        "leather",
        "candle wax",
        "choking",
        "collar and lead/leash",
        "corsets",
        "crops",
        "cross dressing",
        "cuddling",
        "curvy pervy girls",
        "deep penetration",
        "dildos",
        "girl's crazy",
        "face fucking",
        "female ejaculation",
        "blood play",
        "blow jobs",
        "bondage",
        "breath play",
        "bruises",
    ]
    
    var customTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagListView.textFont = UIFont.init(name: "Helvetica", size: 14)!
        customTagListView.textFont = UIFont.init(name: "Helvetica", size: 14)!
        customTags = (APPDELEGATE.currentUser?.customFetishes)!
        let tagViews = tagListView.addTags(tags)
        for tagView in tagViews {
            if (APPDELEGATE.currentUser?.fetishes.contains(tagView.currentTitle!))!{
                tagView.isSelected = true
            }
        }

        let customTagViews = customTagListView.addTags(customTags)
        for tagView in customTagViews {
            tagView.isSelected = true
        }
        
        tagListView.delegate = self
        customTagListView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPressedAddTag(_ sender: Any) {
        var tag = customTagField.text ?? ""
        tag = tag.trimmingCharacters(in: .whitespaces)
        if !tag.isEmpty && !customTags.contains(tag) {
            customTags.append(tag)
            customTagListView.addTag(tag)
            customTagField.text = ""
        }
    }
    
    @IBAction func onPressedSaveBtn(_ sender: Any) {
        let selectedTagViews = tagListView.selectedTags()
        let selectedTags = selectedTagViews.map {
            $0.currentTitle ?? ""
        }
        
        let joinedStr = selectedTags.joined(separator: ", ")
        
        let selectedCustomTagViews = customTagListView.selectedTags()
        let selectedCustomTags = selectedCustomTagViews.map {
            $0.currentTitle ?? ""
        }
        
        let joinedCustomTagsStr = selectedCustomTags.joined(separator: ", ")
        
        let fetishesSTr = "\(joinedStr)\n\(joinedCustomTagsStr)"
        
        FirebaseHelper.setUserDic(dic: [USER_FETISHES: fetishesSTr])
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPressedView(_ sender: Any) {
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

extension ChooseFetishesVC: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
    }
}
