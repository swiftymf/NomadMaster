//
//  ResultsViewController.swift
//  NomadMaster
//
//  Created by Markith on 7/31/19.
//  Copyright © 2019 Markith. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel
import Firebase

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var matchingItems:[MKMapItem] = []
    var items: [LocationObject] = []
    var fpc = FloatingPanelController()
    var vc = ViewController()
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
//        tableView.delegate = self
//        tableView.dataSource = self
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            selectedItem.thoroughfare ?? "",
            comma,
            selectedItem.locality ?? "",
            secondSpace,
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}

extension ResultsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return 1//matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
//        let locationItem = items[indexPath.row]
//        cell.textLabel?.text = locationItem.name
//        cell.detailTextLabel?.text = locationItem.address
        // This works for searching for locations
     //   let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = "HI"//selectedItem.name
        cell.detailTextLabel?.text = "hello"//parseAddress(selectedItem: selectedItem)
        return cell
    }

    
    // TODO: - Show pin for location selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if fpc.isViewLoaded {
//            fpc.dismiss(animated: true, completion: nil)
//        }
//        // show new Floating Panel with details of the location
//        fpc = FloatingPanelController()
//        var locationDetailsVC = LocationDetailsViewController()
//        locationDetailsVC = (storyboard?.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController)!
//        let selectedItem = matchingItems[indexPath.row]
//
//        let coordinate = selectedItem.placemark.coordinate
//        let item = LocationObject(name: selectedItem.name ?? "", comment: [], address: parseAddress(selectedItem: selectedItem.placemark), longitude: coordinate.longitude, latitude: coordinate.latitude)
//
//        locationDetailsVC.selectedLocation = item
//        fpc.set(contentViewController: locationDetailsVC)
//        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
//        self.present(fpc, animated: true, completion: nil)
//
//        // place pin on map when a location is selected
//        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem.placemark)

        // instead of dismiss, lower to .tip (or whatever it's called to the bottom of the view)
//        dismiss(animated: true, completion: nil)
    }
}

