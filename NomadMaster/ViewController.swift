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
    func loadDetailsFromPin(locationObject: LocationObject)
    
}

class ViewController: UIViewController, FloatingPanelControllerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    var ref: DatabaseReference!
    var locationManager = CLLocationManager()
    
    var floatingResultsView: FloatingPanelController!
    var floatingDetailsView: FloatingPanelController!
    var resultsVC: ResultsViewController!
    var locationDetailsVC: LocationDetailsViewController!
    var selectedPin: MKPlacemark? = nil
    var matchingItems:[MKMapItem] = []
    var items: [LocationObject] = []
    var resultSearchController: UISearchController? = nil
    var userLocation = CLLocation()
    
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
        mapView.delegate = self
        
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultsViewController
        floatingDetailsView = FloatingPanelController()
        locationDetailsVC = (storyboard?.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController)!
        
        ref = Database.database().reference(withPath: "userFeedback")
        floatingResultsView = FloatingPanelController()
        floatingResultsView.delegate = self
        
        floatingResultsView.set(contentViewController: resultsVC)
        floatingResultsView.track(scrollView: resultsVC?.tableView)
        floatingResultsView.addPanel(toParent: self)
        view.addSubview(floatingResultsView.view)
        loadNearbyLocations()
    }
    
    @IBAction func centerOnUserButton(_ sender: UIButton) {
        guard let userLocationCoordinates: CLLocation = locationManager.location else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: userLocationCoordinates.coordinate, span: span)
        mapView.setRegion(region, animated: true)
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
            self.sortLocationNearestToUser()
        })
    }
    
    func sortLocationNearestToUser() {
        // Update to only save locations within current map region
        // if zoomed in, zoom map out to some level
        // see if location is within map region and then sort my distance to user
        // this needs to happen for the pin annotations too
        
        //        if mapView.contains(coordinate: CLLocationCoordinate2D) { add to array for sorting by distance }
        var itemsInMapRegion: [LocationObject] = []
        
        for item in items {
            let location = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            if mapView.contains(coordinate: location) {
                itemsInMapRegion.append(item)
            }
        }
        
        
//        let sortedPlaces = items.sorted {
        let sortedPlaces = itemsInMapRegion.sorted {
            userLocation.distance(from: $0.location) < userLocation.distance(from: $1.location)
        }
        print("itemsIn: \(itemsInMapRegion)")
        resultsVC.items = sortedPlaces
        resultsVC.tableView.reloadData()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "pin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = true
        }
        else {
            annotationView?.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        annotationView?.image = UIImage(named:cpa.imageName)
        annotationView?.frame.size = CGSize(width: 40, height: 40)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedAnnotation = view.annotation
        for item in items {
            // item DOES exists in DB...
            if selectedAnnotation?.coordinate.latitude == item.latitude && selectedAnnotation?.coordinate.longitude == item.longitude {
                loadDetailsFromPin(locationObject: item)
                break
            } else {
                // item DOES NOT exist in DB...
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapView.contains(coordinate: mapView.centerCoordinate) {
            // do stuff
        }
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        //mapView.removeAnnotations(mapView.annotations)
        
        let annotation = CustomPointAnnotation()//MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.imageName = "pinIcon"
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        //  Show DetailsVC and populate with info from placemark
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func loadDetailsView(placemark: MKPlacemark) {        
        if locationDetailsVC.isViewLoaded {
            locationDetailsVC.dismiss(animated: true, completion: nil)
        }
        
        let coordinate = placemark.coordinate
        let item = LocationObject(name: placemark.name ?? "", commentDict: [], address: parseAddress(selectedItem: placemark), longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        locationDetailsVC.selectedLocation = item
        floatingDetailsView.set(contentViewController: locationDetailsVC)
        floatingDetailsView.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        self.present(floatingDetailsView, animated: true, completion: nil)
        
    }
    
    func loadDetailsFromPin(locationObject: LocationObject) {
        if locationDetailsVC.isViewLoaded {
            locationDetailsVC.dismiss(animated: true, completion: nil)
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: locationObject.latitude, longitude: locationObject.longitude)
        let item = LocationObject(name: locationObject.name, commentDict: locationObject.commentDict, address: locationObject.address, longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        locationDetailsVC.selectedLocation = item
        floatingDetailsView.set(contentViewController: locationDetailsVC)
        floatingDetailsView.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        self.present(floatingDetailsView, animated: true, completion: nil)
        
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
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
            guard let userLocationCoordinates: CLLocation = manager.location else { return }
            userLocation = userLocationCoordinates
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}

extension MKMapView {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return self.visibleMapRect.contains(MKMapPoint(coordinate))
    }
    
}
