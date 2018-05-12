//
//  DungeonInfoWindow.swift
//  Spankrr
//
//  Created by Kangtle on 2/1/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class DungeonInfoWindow: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var dungeon: Dungeon? {
        didSet{
            titleLabel.text = dungeon?.name
            let picRef = STORAGE_REF.child((dungeon?.photoUrl)!)
            imageView.sd_setImage(with: picRef)
            setScoreLabel(score: (dungeon?.score.avg)!)
        }
    }
    
    func setScoreLabel(score: Double) {
        let scoreStr = score.format(f: ".1")
        let star = #imageLiteral(resourceName: "star").scaleImage(newHeight: scoreLabel.font.lineHeight)
        scoreLabel.attributedText = scoreStr.attributedStringWithImage(at: 0, image: star)
    }

    init() {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 145))
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
        Bundle.main.loadNibNamed("DungeonInfoWindow", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
