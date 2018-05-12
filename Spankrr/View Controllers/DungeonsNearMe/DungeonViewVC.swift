//
//  DungeonViewVC.swift
//  Spankrr
//
//  Created by Kangtle on 2/2/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class DungeonViewVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imagePagingScrollView: UIScrollView!
    @IBOutlet weak var imagePagingContentView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    
    @IBOutlet weak var cleanlinessScoreLabel: UILabel!
    @IBOutlet weak var comfortScoreLabel: UILabel!
    @IBOutlet weak var locationScoreLabel: UILabel!
    @IBOutlet weak var facilitiesScoreLabel: UILabel!

    @IBOutlet weak var cleanlinessSlider: UISlider!
    @IBOutlet weak var comfortSlider: UISlider!
    @IBOutlet weak var locationSlider: UISlider!
    @IBOutlet weak var facilitiesSlider: UISlider!
    @IBOutlet weak var reviewsView: UIView!
    
    var dungeon: Dungeon!
    var owner: User!
    var reviews = [Review]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupImagePaging()
        setupDungeonDetails()
        setupScores()
        getReviews()
        
        setupReviews()
    }

    func setupImagePaging() {
        let width = Int(imagePagingScrollView.frame.width)
        let height = Int(imagePagingScrollView.frame.height)
        let fullWidth = width * dungeon.photos.count
        imagePagingScrollView.contentSize = CGSize(width: fullWidth, height: 0)
        imagePagingContentView.frame = CGRect.init(x: 0, y: 0, width: fullWidth, height: height)
        var index = 0
        for photoUrl in dungeon.photos {
            let imageView = UIImageView()
            imageView.frame = CGRect.init(x: width * index, y: 0, width: width, height: height)
            imageView.contentMode = .scaleAspectFill

            let picRef = STORAGE_REF.child(photoUrl)
            imageView.sd_setImage(with: picRef)
            
            imagePagingContentView.addSubview(imageView)
            
            index = index + 1
        }
        imagePagingScrollView.delegate = self
        pageControl.numberOfPages = dungeon.photos.count
    }
    
    func setupDungeonDetails() {
        ownerImageView.makeCircularView()
        
        titleLabel.text = dungeon.name.capitalizingFirstLetter()
        descriptionLabel.text = dungeon.description
        descriptionLabel.sizeToFit()
        FirebaseHelper.getUserBy(uid: dungeon.ownerId) { (user) in
            if user != nil {
                self.owner = user
                let picRef = STORAGE_REF.child((user?.pictureUrl)!)
                self.ownerImageView.sd_setImage(with: picRef)
                self.ownerNameLabel.text = user?.name
            }
        }
    }
    
    func setupScores() {
        scoreLabel.text = dungeon.score.avg.format(f: ".1")
        reviewCountLabel.text = "Based on \(dungeon.reviewCount) reviews"

        cleanlinessScoreLabel.text = dungeon.score.cleanliness.format(f: ".1")
        comfortScoreLabel.text = dungeon.score.comfort.format(f: ".1")
        locationScoreLabel.text = dungeon.score.location.format(f: ".1")
        facilitiesScoreLabel.text = dungeon.score.facilities.format(f: ".1")
        
        cleanlinessSlider.value = Float(dungeon.score.cleanliness)
        comfortSlider.value = Float(dungeon.score.comfort)
        locationSlider.value = Float(dungeon.score.location)
        facilitiesSlider.value = Float(dungeon.score.facilities)
    }
    
    func getReviews() {
        FirebaseHelper.dungeonReviewsRef.child(dungeon.id).observe(.childAdded, with: { (snapshot) in
            if let reviewDic = snapshot.value as? [String: Any] {
                let review = Review.init(dic: reviewDic, reviewID: snapshot.key)
                self.reviews.insert(review, at: 0)
                self.setupReviews()
            }
        })
    }
    
    func setupReviews() {
        reviewsView.subviews.forEach({ $0.removeFromSuperview() })

        let width = Int(reviewsView.frame.width)
        var index = 0
        var y = 0
        for review in reviews {
            let rect = CGRect.init(x: 0, y: y, width: width, height: 0)
            let reviewView = ReviewView.init(frame: rect)
            reviewView.review = review
            reviewsView.addSubview(reviewView)
            y = y + Int(reviewView.frame.height)
            index = index + 1
        }
        
        reviewsView.frame.size.height = CGFloat(y)

        let scrollContentView = reviewsView.superview
        scrollContentView?.frame.size.height = reviewsView.frame.maxY
        scrollView.contentSize.height = (scrollContentView?.frame.maxY)!
    }
    
    @IBAction func onClose(_ sender: Any) {
        performSegueToReturnBack()
    }
    
    @IBAction func onMessageOwner(_ sender: Any) {
        if owner.uid == APPDELEGATE.currentUser?.uid ?? "" {
            return
        }
        FirebaseHelper.isContactedUser(uid: dungeon.ownerId ) { (_channelID) in
            if let channelID = _channelID {
                var channel = ChatChannel()
                channel.id = channelID
                channel.name = self.owner.name
                channel.users = [self.owner]
                
                let chatVC = ChatVC()
                chatVC.channel = channel
                let chatNavigationController = UINavigationController(rootViewController: chatVC)
                self.present(chatNavigationController, animated: true, completion: nil)
            }else{
                let newChatChannelID =  FirebaseHelper.newChatChannelByCurrentUser(otherUserIds: [self.dungeon.ownerId])
                var channel = ChatChannel()
                channel.id = newChatChannelID
                channel.name = self.owner.name
                channel.users = [self.owner]
                
                let chatVC = ChatVC()
                chatVC.channel = channel
                let chatNavigationController = UINavigationController(rootViewController: chatVC)
                self.present(chatNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onWriteReview(_ sender: Any) {
        if owner.uid == APPDELEGATE.currentUser?.uid ?? "" {
            return
        }
        let writeReviewVC = STORYBOARD.instantiateViewController(withIdentifier: "WriteReviewVC") as! WriteReviewVC
        writeReviewVC.dungeon = dungeon
        present(writeReviewVC, animated: true, completion: nil)
    }
}

extension DungeonViewVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ _scrollView: UIScrollView) {
        if _scrollView === imagePagingScrollView {
            let pageWidth = _scrollView.frame.size.width
            let currentPosition = _scrollView.contentOffset.x
            let currentPage = currentPosition/pageWidth
            pageControl.currentPage = Int(currentPage)
        }
    }
}
