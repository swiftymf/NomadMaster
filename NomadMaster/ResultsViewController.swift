//
//  ResultsViewController.swift
//  NomadMaster
//
//  Created by Markith on 7/31/19.
//  Copyright © 2019 Markith. All rights reserved.
//

import UIKit
// MapKit for search request
// Can move some logic to other view or leave it here?
import MapKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cellTextForFunsies = "Hello, I'm a cell"
    var cellDetailTextForFunsies = "I'm also a superstar!"
    
    var mapSearchController = UISearchController(searchResultsController: nil)
    // for searching
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // maybe I need to programmatically add the search bar? 
        searchBar = mapSearchController.searchBar
//        mapSearchController.hidesNavigationBarDuringPresentation = false
//        mapSearchController.dimsBackgroundDuringPresentation = true
//        definesPresentationContext = true
        
        mapSearchController.searchResultsUpdater = self
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        viewController?.mapView = mapView
        
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
        cell.detailTextLabel?.text = "address"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell at \(indexPath.row) tapped")
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        print("this is happening")
        guard let mapView = mapView,
            let searchBarText = searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            print(self.matchingItems)
            self.tableView.reloadData()
        }
    }
}

extension ResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

