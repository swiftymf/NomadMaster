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
}

class ViewController: UIViewController, FloatingPanelControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    var ref: DatabaseReference!
    
    var floatingPanel: FloatingPanelController!
    var locationManager = CLLocationManager()
    var resultsVC: ResultsViewController!
    var locationDetailsVC: LocationDetailsViewController!
    var selectedPin: MKPlacemark? = nil
    var items: [LocationObject] = []
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "resultsViewController") as? ResultsViewController
        resultsVC.mapView = mapView
        locationDetailsVC = storyboard?.instantiateViewController(withIdentifier: "LocationDetailsViewController") as? LocationDetailsViewController

        
        ref = Database.database().reference(withPath: "userFeedback")
        locationManager.delegate = self
        mapView.delegate = self
        centerOnUserLocation()
        // after getting user location, load nearby locations from database
        resultsVC.handleMapSearchDelegate = self
        
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
        resultsVC.mapSearchController.searchBar.delegate = self
        
    }
    func centerOnUserLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        resultsVC.matchingItems.removeAll()
        resultsVC.tableView.reloadData()
        floatingPanel.move(to: .half, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        resultsVC.tableView.alpha = 1.0
        resultsVC.fpc.dismiss(animated: true, completion: nil)
        floatingPanel.move(to: .full, animated: true)
    }
    
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
        // Show detailsVC when annotation is selected? or do something like that
        
        
        // PIN ISN'T CHANGING DETAILS. WHATEVER THE FIRST ONE SELECTED IS STAY THAT ONE
        
        
        
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
        let region = MKCoordinateRegion(center: placemark.coordinate, latitudinalMeters: 10.0, longitudinalMeters: 10.0)
        mapView.setRegion(region, animated: true)
    }
    
}
