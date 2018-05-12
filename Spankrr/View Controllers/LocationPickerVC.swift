//
//  LocationPickerVC.swift
//  Spankrr
//
//  Created by Kangtle on 1/29/18.
//  Copyright © 2018 Kangtle. All rights reserved.
//

import UIKit
import GoogleMaps
import MBProgressHUD

class LocationPickerVC: UIViewController {

    let marker = GMSMarker()
    
    var location: CLLocationCoordinate2D?
    var onPickLocation: ((CLLocationCoordinate2D, String)->())!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = BACKGROUND_COLOR_2
        setupToolbar()
        
        var camera = GMSCameraPosition.init()
        if  location != nil{
            marker.position = location!
            camera = GMSCameraPosition.camera(withTarget: location!, zoom: 12.0)
        }else{
            if let curLocation = LOC_MANAGER.location {
                marker.position = curLocation.coordinate
                camera = GMSCameraPosition.camera(withTarget: curLocation.coordinate, zoom: 12.0)
            }
        }

        let mapView = GMSMapView.map(
                            withFrame: CGRect.init(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 64),
                            camera: camera
        )
        view.addSubview(mapView)

        mapView.delegate = self
        
        marker.map = mapView
        marker.title = "Dungeon's Location"

    }
    
    func setupToolbar() {
        let toolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 20, width: view.frame.width, height: 44))
        toolbar.barTintColor = BACKGROUND_COLOR_2
        toolbar.isTranslucent = false
        let closeItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "btn_close"), style: .plain, target: self, action: #selector(onCancel))
        closeItem.tintColor = .white
        let titleItem = UIBarButtonItem.init(title: "SELECT LOCATION", style: .plain, target: self, action: nil)
        titleItem.tintColor = .white
        let okItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "btn_check"), style: .plain, target: self, action: #selector(onPick))
        okItem.tintColor = RED_COLOR
        toolbar.items = [
            closeItem,
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            titleItem,
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            okItem
        ]
        view.addSubview(toolbar)
    }

    func onCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    func onPick(){
        let geocoder = GMSGeocoder()
        
        let pHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        pHud.label.text = "Please wait..."

        geocoder.reverseGeocodeCoordinate(marker.position) { (response, error) in

            pHud.hide(animated: true)
            self.dismiss(animated: true, completion: nil)

            guard error == nil else {
                self.onPickLocation(self.marker.position, "")
                return
            }
            
            if let result = response?.firstResult() {
                let address = "\(result.locality ?? ""), \(result.country ?? "")"
                self.onPickLocation(self.marker.position, address)
            }
        }
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

extension LocationPickerVC: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.marker.position = coordinate
    }
}
