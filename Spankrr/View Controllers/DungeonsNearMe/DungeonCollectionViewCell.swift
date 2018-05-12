//
//  DungeonCollectionViewCell.swift
//  Spankrr
//
//  Created by Kangtle on 2/14/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class DungeonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var dungeon: Dungeon? {
        didSet{
            let photoRef = STORAGE_REF.child((dungeon?.photoUrl)!)
            imageView.sd_setImage(with: photoRef, placeholderImage: #imageLiteral(resourceName: "bunnyears"))
            
            titleLabel.text = dungeon?.name.uppercased()
            setScoreLabel(score: (dungeon?.score.avg)!)
        }
    }
    
    func setScoreLabel(score: Double) {
        let scoreStr = score.format(f: ".1")
        let star = #imageLiteral(resourceName: "star").scaleImage(newHeight: scoreLabel.font.lineHeight)
        scoreLabel.attributedText = scoreStr.attributedStringWithImage(at: 0, image: star)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
