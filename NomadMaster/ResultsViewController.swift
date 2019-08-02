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

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mapSearchController = UISearchController(searchResultsController: nil)
    // for searching
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var fpc = FloatingPanelController()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        mapSearchController.searchResultsUpdater = self
        mapSearchController.hidesNavigationBarDuringPresentation = false
        mapSearchController.obscuresBackgroundDuringPresentation = false
        mapSearchController.dimsBackgroundDuringPresentation = true
        mapSearchController.definesPresentationContext = true
        
        tableView.tableHeaderView = mapSearchController.searchBar
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
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
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell at \(indexPath.row) tapped")
        
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
}

extension ResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: mapSearchController)
    }
}

