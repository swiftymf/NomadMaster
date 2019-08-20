//
//  ViewController.swift
//  NomadMaster
//
//  Created by Markith on 7/31/19.
//  Copyright © 2019 Markith. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel
import Firebase

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
    func loadDetailsView(placemark: MKPlacemark)
}

class ViewController: UIViewController, FloatingPanelControllerDelegate, UISearchBarDelegate {
    
    var ref: DatabaseReference!
    var locationManager = CLLocationManager()

    var floatingPanel: FloatingPanelController!
    var resultsVC: ResultsViewController!
    var locationDetailsVC: LocationDetailsViewController!
    var selectedPin: MKPlacemark? = nil
    var matchingItems:[MKMapItem] = []
    var items: [LocationObject] = []
    var resultSearchController: UISearchController? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultsViewController
        locationDetailsVC = storyboard?.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController

        
        ref = Database.database().reference(withPath: "userFeedback")
        floatingPanel = FloatingPanelController()
        floatingPanel.delegate = self
        
        floatingPanel.set(contentViewController: resultsVC)
        floatingPanel.track(scrollView: resultsVC?.tableView)
        floatingPanel.addPanel(toParent: self)
        view.addSubview(floatingPanel.view)
        loadNearbyLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        floatingPanel.addPanel(toParent: self, animated: true)
        
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // whatever searchResults are showing should populate the mapView and ResultsTableView
        // dismiss searchController tableView
        dismiss(animated: true, completion: nil)
    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        searchBar.showsCancelButton = false
//        resultsVC.matchingItems.removeAll()
//        resultsVC.tableView.reloadData()
//    }
//    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = true
//        resultsVC.tableView.alpha = 1.0
//        resultsVC.fpc.dismiss(animated: true, completion: nil)
//    }
    
    func loadNearbyLocations() {
        
        ref.observe(.value, with: { snapshot in
            var newItems: [LocationObject] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let location = LocationObject(snapshot: snapshot) {
                    newItems.append(location)
                    
                    let annotation = MKPointAnnotation()
                    annotation.title = location.name
                    annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    self.mapView.addAnnotation(annotation)
                }
            }
            self.items = newItems
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // PIN ISN'T CHANGING DETAILS. WHATEVER THE FIRST ONE SELECTED IT STAYS THAT ONE
        
        print("someone touched an annotation")
        let selectedAnnotation = view.annotation
        for item in items {
            // item DOES exists in DB...
            if selectedAnnotation?.coordinate.latitude == item.latitude && selectedAnnotation?.coordinate.longitude == item.longitude {
                // pass info to detailsVC
                locationDetailsVC.selectedLocation = item
                
//                locationDetailsVC.nameText = selectedItem.name ?? "Name unavailable"
//                locationDetailsVC.phoneText = selectedItem.phoneNumber ?? "Phone number unavailable"
//                locationDetailsVC.addressText = parseAddress(selectedItem: selectedItem.placemark)
//                locationDetailsVC.locationSelected = selectedItem
                floatingPanel = FloatingPanelController()
                floatingPanel.set(contentViewController: locationDetailsVC)
                floatingPanel.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
                self.present(floatingPanel, animated: true, completion: nil)
                break
            } else {
                // item DOES NOT exist in DB...
            }
        }
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        mapView.addAnnotation(annotation)
        //  Show DetailsVC and populate with info from placemark
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func loadDetailsView(placemark: MKPlacemark) {
        if floatingPanel.isViewLoaded {
            floatingPanel.dismiss(animated: true, completion: nil)
        }
        // show new Floating Panel with details of the location
        floatingPanel = FloatingPanelController()
        var locationDetailsVC = LocationDetailsViewController()
        locationDetailsVC = (storyboard?.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController)!
       
        
        let coordinate = placemark.coordinate
        let item = LocationObject(name: placemark.name ?? "", comment: [], address: parseAddress(selectedItem: placemark), longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        locationDetailsVC.selectedLocation = item
        floatingPanel.set(contentViewController: locationDetailsVC)
        floatingPanel.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        self.present(floatingPanel, animated: true, completion: nil)

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

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}
