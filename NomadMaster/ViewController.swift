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

class ViewController: UIViewController, FloatingPanelControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {

    var floatingPanel: FloatingPanelController!
    var locationManager = CLLocationManager()
    var resultsVC: ResultsViewController!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        showFloatingPanel()
        centerOnUserLocation()

    }

    func showFloatingPanel() {
        floatingPanel = FloatingPanelController()
        floatingPanel.delegate = self
        
        resultsVC = storyboard?.instantiateViewController(withIdentifier: "resultsViewController") as? ResultsViewController
        resultsVC.mapView = mapView
        
        floatingPanel.set(contentViewController: resultsVC)
        floatingPanel.track(scrollView: resultsVC?.tableView)
        floatingPanel.addPanel(toParent: self)
        view.addSubview(floatingPanel.view)
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
}

