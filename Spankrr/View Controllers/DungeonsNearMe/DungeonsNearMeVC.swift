//
//  DungeonsNearMeVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/17/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI
import GeoFire
import GoogleMaps
import Pulley
import GooglePlaces

class DungeonsNearMeVC: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    var dungeons = [Dungeon]()

    var markers = [GMSMarker]()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 64, width: 250, height: 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.searchBar.searchBarStyle = .minimal

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        searchController?.modalPresentationStyle = .popover

        mapView.delegate = self
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        
        if let myLocation = LOC_MANAGER.location {
            searchDungeons(coordinate: myLocation.coordinate)
        }
    }
    
    func searchDungeons(coordinate: CLLocationCoordinate2D){
        self.dungeons.removeAll()
        self.markers.removeAll()
        
        if let parent = self.parent as? PulleyViewController {
            let drawerVC = parent.drawerContentViewController as! DungeonDrawerVC
            drawerVC.dungeons.removeAll()
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 12.0)
        mapView.camera = camera
        
        let circleQuery = GEOFIRE_DUNGEONS.query(at: location, withRadius: NEAR_BY_RADIUS)
        circleQuery.observe(.keyEntered) { (key, location) in
            let dungeonID = key
            FirebaseHelper.dungeonsRef.child(dungeonID).observe(.value, with: {snapshot in
                if let dungeonDic = snapshot.value as? [String : Any] {
                    if let exstingIndex = self.dungeons.index(where: {$0.id == dungeonID}) {
                        self.dungeons.remove(at: exstingIndex)
                        self.markers.remove(at: exstingIndex)
                        if let parent = self.parent as? PulleyViewController {
                            let drawerVC = parent.drawerContentViewController as! DungeonDrawerVC
                            drawerVC.dungeons.remove(at: exstingIndex)
                        }
                    }
                    
                    let dungeon = Dungeon(dic: dungeonDic, dungeonID: dungeonID)
                    
                    self.dungeons.append(dungeon)
                    
                    if let parent = self.parent as? PulleyViewController {
                        let drawerVC = parent.drawerContentViewController as! DungeonDrawerVC
                        drawerVC.dungeons.append(dungeon)
                    }
                    
                    let marker = GMSMarker()
                    marker.position = dungeon.location
                    marker.title = dungeon.name
                    marker.snippet = dungeon.address
                    marker.icon = #imageLiteral(resourceName: "dungeon_marker")
                    marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                    marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
                    marker.map = self.mapView
                    
                    self.markers.append(marker)
                    
                    self.mapView.animate(toLocation: dungeon.location)
                }
            })
        }
        circleQuery.observeReady({
            print("all initial data loaded")
        })
    }
    
    func gotoDungeonView(dungeon: Dungeon) {
        let dungeonViewVC = STORYBOARD.instantiateViewController(withIdentifier: "DungeonViewVC") as! DungeonViewVC
        dungeonViewVC.dungeon = dungeon
        present(dungeonViewVC, animated: true, completion: nil)
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

extension DungeonsNearMeVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {

        let markerIndex = markers.index(of: marker)
        
        let infoWindow = DungeonInfoWindow()
        
        infoWindow.dungeon = dungeons[markerIndex!]
        
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
//        let markerIndex = markers.index(of: marker)
//        gotoDungeonView(dungeon: dungeons[markerIndex!])
    }
}

// Handle the user's selection.
extension DungeonsNearMeVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress ?? "")")
        self.searchDungeons(coordinate: place.coordinate)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
