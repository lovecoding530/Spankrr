//
//  DungeonTableViewCell.swift
//  Spankrr
//
//  Created by Kangtle on 1/28/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit

class DungeonTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var laceView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var dungeon: Dungeon? {
        didSet{
            let photoRef = STORAGE_REF.child((dungeon?.photoUrl)!)
            photoImageView.sd_setImage(with: photoRef, placeholderImage: #imageLiteral(resourceName: "bunnyears"))
            
            nameLabel.text = dungeon?.name
            setLocationLabel(location: (dungeon?.address)!)
            detailLabel.text = dungeon?.description
//            detailLabel.sizeToFit()
            setScoreLabel(score: (dungeon?.score.avg)!)
            laceView.isHidden = !(dungeon?.featured)!
        }
    }
    
    func setLocationLabel(location: String) {
        let marker = #imageLiteral(resourceName: "Pin").scaleImage(newHeight: locationLabel.font.lineHeight)
        locationLabel.attributedText = location.attributedStringWithImage(at: 0, image: marker)
    }

    func setScoreLabel(score: Double) {
        let scoreStr = score.format(f: ".1")
        let star = #imageLiteral(resourceName: "star").scaleImage(newHeight: scoreLabel.font.lineHeight)
        scoreLabel.attributedText = scoreStr.attributedStringWithImage(at: 0, image: star)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoImageView.makeCircularView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
