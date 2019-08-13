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

    var mapSearchController = UISearchController(searchResultsController: nil)
    // for searching
    var matchingItems:[MKMapItem] = []
    var items: [LocationObject] = []
    var mapView: MKMapView? = nil
    var fpc = FloatingPanelController()
    var vc = ViewController()
    
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        mapSearchController.searchResultsUpdater = self
        mapSearchController.hidesNavigationBarDuringPresentation = false
        mapSearchController.obscuresBackgroundDuringPresentation = false
//        mapSearchController.definesPresentationContext = false
        mapSearchController.searchBar.barTintColor = .white
//        mapSearchController.searchBar.searchBarStyle = .minimal
        
        // TODO: - while text if being edited, if user drags up tableView, the searchBar stays in place, fix that
        tableView.tableHeaderView = mapSearchController.searchBar
        definesPresentationContext = false
        loadNearbyLocations()
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
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
//        let locationItem = items[indexPath.row]
//        cell.textLabel?.text = locationItem.name
//        cell.detailTextLabel?.text = locationItem.address
//        return cell

        // This works for searching for locations
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }

    
    // TODO: - Show pin for location selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if fpc.isViewLoaded {
            fpc.dismiss(animated: true, completion: nil)
        } else if mapSearchController.isViewLoaded {
            mapSearchController.dismiss(animated: true, completion: nil)
        }
        // show new Floating Panel with details of the location
        fpc = FloatingPanelController()
        var locationDetailsVC = LocationDetailsViewController()
        locationDetailsVC = (storyboard?.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController)!
        
        locationDetailsVC.nameText = matchingItems[indexPath.row].name ?? "Name unavailable"
        locationDetailsVC.phoneText = matchingItems[indexPath.row].phoneNumber ?? "Phone number unavailable"
        locationDetailsVC.addressText = parseAddress(selectedItem: matchingItems[indexPath.row].placemark) 
        fpc.set(contentViewController: locationDetailsVC)
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        self.present(fpc, animated: true, completion: nil)
        
        // place pin on map when a location is selected
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)

        // instead of dismiss, lower to .tip (or whatever it's called to the bottom of the view)
//        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return mapSearchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        guard let mapView = mapView,
         let searchBarText = mapSearchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func loadNearbyLocations() {
        
        ref.queryOrdered(byChild: "userFeedback").observe(.value, with: { snapshot in
        
            // This is loading the info from Firebase
//            print("snapshot: \(snapshot.value as Any)")
            var newItems: [LocationObject] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let locationObject = LocationObject(snapshot: snapshot) {
                    
                    // Not appending, probably because the data isn't coming back in the same format as LocationObject
                    newItems.append(locationObject)
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        
    }

}

extension ResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: mapSearchController)
    }
    

}

