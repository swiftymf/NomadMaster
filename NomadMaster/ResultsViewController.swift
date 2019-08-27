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
    }
}

extension ResultsViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let selectedItem = items[indexPath.row]
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.address
        return cell
    }
    
    // TODO: - Show pin for location selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if fpc.isViewLoaded {
            fpc.dismiss(animated: true, completion: nil)
        }
        // show new Floating Panel with details of the location
        fpc = FloatingPanelController()
        var locationDetailsVC = LocationDetailsViewController()
        locationDetailsVC = (storyboard?.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController)!
        let selectedItem = items[indexPath.row]

        let coordinate = selectedItem.location.coordinate
        let item = LocationObject(name: selectedItem.name, commentDict: [], address: selectedItem.address, longitude: coordinate.longitude, latitude: coordinate.latitude)

        locationDetailsVC.selectedLocation = item
        fpc.set(contentViewController: locationDetailsVC)
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        self.present(fpc, animated: true, completion: nil)

        // place pin on map when a location is selected
//        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem.placemark)

    }
}

