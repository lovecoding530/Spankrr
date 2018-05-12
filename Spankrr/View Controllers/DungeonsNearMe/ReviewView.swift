//
//  ReviewView.swift
//  Spankrr
//
//  Created by Kangtle on 2/2/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class ReviewView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var advantageView: UIView!
    @IBOutlet weak var disAdvantageView: UIView!
    @IBOutlet weak var advantageLabel: UILabel!
    @IBOutlet weak var disadvantageLabel: UILabel!
    
    var review: Review! {
        didSet {
            FirebaseHelper.getUserBy(uid: review.writerId) { (user) in
                if user != nil{
                    let picRef = STORAGE_REF.child((user?.pictureUrl)!)
                    self.userImageView.sd_setImage(with: picRef)
                    self.userNameLabel.text = user?.name
                    self.setLocationLabel(location: (user?.address)!)
                }
            }
            
            scoreLabel.text = review.score.avg.format(f: ".1")
            reviewTitleLabel.text = review.title
            advantageLabel.text = review.advantage.isEmpty ? "No provided" : review.advantage
            disadvantageLabel.text = review.disadvantage.isEmpty ? "No provided" : review.disadvantage
            timeLabel.text = review.timeStr
            
            advantageLabel.sizeToFit()
            disadvantageLabel.sizeToFit()
            
            advantageView.frame.size.height = max(25, advantageLabel.frame.height)
            disAdvantageView.frame.size.height = max(25, disadvantageLabel.frame.height)
            disAdvantageView.frame.origin.y = advantageView.frame.maxY + 8
            
            self.frame.size.height = disAdvantageView.frame.maxY + 20
        }
    }
    
    func setLocationLabel(location: String) {
        let marker = #imageLiteral(resourceName: "Pin").scaleImage(newHeight: userLocationLabel.font.lineHeight)
        userLocationLabel.attributedText = location.attributedStringWithImage(at: 0, image: marker)
    }

    init() {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 375, height: 355))
        componentInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        componentInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        componentInit()
    }
    
    func componentInit() {
        Bundle.main.loadNibNamed("ReviewView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        userImageView.makeCircularView()
    }
}
