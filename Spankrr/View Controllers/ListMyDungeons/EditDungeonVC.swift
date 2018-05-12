//
//  EditDungeonVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/28/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Segmentio
import MBProgressHUD
import CoreLocation
import Firebase
import FirebaseStorageUI
import RFQuiltLayout

class EditDungeonVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentio: Segmentio!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var dungeonImageView: UIImageView!
    @IBOutlet weak var dungeonTitleField: UITextField!
    @IBOutlet weak var dungeonDescriptionField: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var titleBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var reviewScollView: UIScrollView!
    @IBOutlet weak var reviewsView: UIView!
    
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
    
    var editingDungeon: Dungeon?
    
    var pickedLocation: CLLocationCoordinate2D!
    
    var photos = [String]()
    
    var reviews = [Review]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        setupCollectionView()
        
        setupSegmentio()
        
        if editingDungeon != nil{
            let photoRef = STORAGE_REF.child((editingDungeon?.photoUrl)!)
            dungeonImageView.sd_setImage(with: photoRef)
            
            dungeonTitleField.text = editingDungeon?.name
            dungeonDescriptionField.text = editingDungeon?.description
            locationLabel.text = editingDungeon?.address
            pickedLocation = editingDungeon?.location
            photos = (editingDungeon?.photos)!
            
            titleBarButtonItem.title = "EDIT DUNGEON"
            
            setupScores()
            getReviews()
            
            setupReviews()
        }
    }
    
    func setupCollectionView(){
        
        let width = photosCollectionView.frame.width
        let layout = photosCollectionView.collectionViewLayout as! RFQuiltLayout
        layout.delegate = self
        layout.direction = .vertical
        layout.blockPixels = CGSize(width: width/4 - 5, height: width/4 - 5);
        
        photosCollectionView.dragDelegate = self
        photosCollectionView.dropDelegate = self
        photosCollectionView.dragInteractionEnabled = true

    }
    
    func setupSegmentio(){
        var content = [SegmentioItem]()
        let detailItem = SegmentioItem(
            title: "DETAIL",
            image: #imageLiteral(resourceName: "dungeon_detail")
        )
        let photoItem = SegmentioItem(
            title: "PHOTOS",
            image: #imageLiteral(resourceName: "photo")
        )
        let reviewItem = SegmentioItem(
            title: "REVIEWS",
            image: #imageLiteral(resourceName: "dungeon_detail")
        )
        content.append(detailItem)
        content.append(photoItem)
        content.append(reviewItem)

        let option = SegmentioOptions(
            backgroundColor: .clear,
            maxVisibleItems: 3,
            scrollEnabled: false,
            indicatorOptions: SegmentioIndicatorOptions(
                type: .bottom,
                ratio: 0.8,
                height: 3,
                color: RED_COLOR
            ),
            horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(
                type: SegmentioHorizontalSeparatorType.bottom, // Top, Bottom, TopAndBottom
                height: 0,
                color: .gray
            ),
            verticalSeparatorOptions: nil,
            imageContentMode: .scaleAspectFit,
            labelTextAlignment: .center,
            labelTextNumberOfLines: 1,
            segmentStates: SegmentioStates(
                defaultState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont: UIFont(name: "Helvetica", size: UIFont.smallSystemFontSize)!,
                    titleTextColor: .lightGray
                ),
                selectedState: SegmentioState(
                    backgroundColor: BACKGROUND_COLOR_3,
                    titleFont: UIFont(name: "Helvetica", size: UIFont.smallSystemFontSize)!,
                    titleTextColor: RED_COLOR
                ),
                highlightedState: SegmentioState(
                    backgroundColor: BACKGROUND_COLOR_3,
                    titleFont: UIFont(name: "Helvetica", size: UIFont.smallSystemFontSize)!,
                    titleTextColor: RED_COLOR
                )
            ),
            animationDuration: 0.1
        )
        
        segmentio.setup(
            content: content,
            style: .imageOverLabel,
            options: option
        )
        
        segmentio.valueDidChange = { segmentio, segmentIndex in
            print("Selected item: ", segmentIndex)
            var index = 0
            for view in self.tabView.subviews {
                view.isHidden = index != segmentIndex
                index = index + 1
            }
        }
        segmentio.selectedSegmentioIndex = 0
    }
    
    
    func setupScores() {
        guard let dungeon = editingDungeon else { return }

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
        guard let dungeon = editingDungeon else { return }
        
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
        reviewScollView.contentSize.height = (scrollContentView?.frame.maxY)!
    }
    
    @IBAction func onEditLocation(_ sender: Any) {
        let locationPickerVC = LocationPickerVC()
        locationPickerVC.onPickLocation = { location, address in
            self.pickedLocation = location
            self.locationLabel.text = address
        }
        present(locationPickerVC, animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        let name = self.dungeonTitleField.text ?? ""
        let desc = self.dungeonDescriptionField.text ?? ""
        let address = self.locationLabel.text ?? ""
        
        if name.isEmpty {
            Helper.showMessage(target: self, message: "Please enter dungeon's title")
            return
        }
        
        if desc.isEmpty {
            Helper.showMessage(target: self, message: "Please enter dungeon's description")
            return
        }
        
        if pickedLocation == nil {
            Helper.showMessage(target: self, message: "Please pick a location of dungeon")
            return
        }
        
        if photos.count == 0 {
            Helper.showMessage(target: self, message: "Please select dungeon's picture")
            return
        }
        
        let uid = APPDELEGATE.currentUser?.uid ?? ""
        
        let dungeonRef: DatabaseReference
        
        if editingDungeon == nil {
            dungeonRef = FirebaseHelper.dungeonsRef.childByAutoId()
        } else {
            dungeonRef = FirebaseHelper.dungeonsRef.child(editingDungeon?.id ?? "")
        }
        
        let dungeonID = dungeonRef.key
        
        let dungeonDic: [String: Any] = [
            DUNGEON_OWNER_ID: uid,
            DUNGEON_NAME: name,
            DUNGEON_DESCRIPTION: desc,
            DUNGEON_LOCATION: [
                LOCATION_LAT: self.pickedLocation.latitude,
                LOCATION_LONG: self.pickedLocation.longitude
            ],
            DUNGEON_ADDRESS: address,
            DUNGEON_PIC_URL: photos.first!,
            DUNGEON_PHOTOS: photos
        ]
        
        dungeonRef.updateChildValues(dungeonDic)

        GEOFIRE_DUNGEONS.setLocation(
            CLLocation(latitude: self.pickedLocation.latitude, longitude: self.pickedLocation.longitude),
            forKey: dungeonID
        )

        FirebaseHelper.userDungeonsRef.child("\(uid)/\(dungeonID)").setValue(true)

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTappedImageView(_ sender: Any) {
        Helper.selectImageSource(viewController: self, isVideo: false)
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


extension EditDungeonVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
            pHud.label.text = "Please wait..."

            let uploadUrl = "images/dungeons/\(Int64(Date().timeIntervalSince1970)).JPG"
            let imagesRef = STORAGE_REF.child(uploadUrl)
            _ = imagesRef.putData(UIImageJPEGRepresentation(image, 0.1)!, metadata: nil) { (metadata, error) in
                pHud.hide(animated: true)
                if error == nil {
                    self.photos.append(uploadUrl)

                    let photoRef = STORAGE_REF.child(self.photos.first!)
                    
                    self.dungeonImageView.sd_setImage(with: photoRef)
                    
                    self.photosCollectionView.reloadData()
                }else{
                    Helper.showMessage(target: self, message: "Can't upload picture")
                }
                
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditDungeonVC: UICollectionViewDelegate, UICollectionViewDataSource, RFQuiltLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < photos.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoView", for: indexPath) as! DungeonPhotoCollectionViewCell
            cell.photoUrl = photos[indexPath.item]

            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressedCell(_:)))
            cell.addGestureRecognizer(lpgr)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAdd", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == photos.count {
            Helper.selectImageSource(viewController: self, isVideo: false)
        }
    }
    
    func insetsForItem(at indexPath: IndexPath!) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 2, 2, 2)
    }
    
    func blockSizeForItem(at indexPath: IndexPath!) -> CGSize {
        if photos.count > 0 && indexPath.row == 0   {
            return CGSize(width: 2, height: 2)
        }else{
            return CGSize(width: 1, height: 1)
        }
    }
    func onLongPressedCell(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .ended {
            let cell = sender.view as! DungeonPhotoCollectionViewCell
            guard let indexPath = photosCollectionView.indexPath(for: cell) else { return }
            
            let optionMenu = UIAlertController(title: nil, message: "Delete selected photo", preferredStyle: .actionSheet)
            
            // 2
            let deleteAction = UIAlertAction(title: "Delete Photo", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                Helper.confirmMessage(target: self, message: "Are you sure to delete this photo?"){
                    self.photos.remove(at: indexPath.item)
                    self.photosCollectionView.reloadData()
                }
            })
            
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            

            // 4
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            
            // 5
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
}

extension EditDungeonVC: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if session.localDragSession != nil
        {
            if collectionView.hasActiveDrag
            {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            else
            {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        }
        else
        {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if (dIndexPath?.item)! >= collectionView.numberOfItems(inSection: 0)
            {
                dIndexPath?.item = collectionView.numberOfItems(inSection: 0) - 1
            }
            collectionView.performBatchUpdates({
                self.photos.remove(at: sourceIndexPath.row)
                self.photos.insert(item.dragItem.localObject as! String, at: (dIndexPath?.item)!)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath!])
            })
            coordinator.drop(item.dragItem, toItemAt: dIndexPath!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.item < photos.count {
            let item = self.photos[indexPath.row]
            let itemProvider = NSItemProvider(object: item as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        }else{
            return []
        }
    }
}

