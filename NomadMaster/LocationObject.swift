//
//  LocationObject.swift
//  NomadMaster
//
//  Created by Markith on 8/7/19.
//  Copyright © 2019 Markith. All rights reserved.
//

import Foundation
import Firebase
import MapKit

struct LocationObject {
    
    let ref: DatabaseReference?
    let key: String
    var name: String
    var commentDict: [[String: String]]  // Change to dictionary? [username: comment]
//    var phoneNumber: String
    var address: String
    var longitude: Double
    var latitude: Double
    
    // TODO: - Add these properties
    //    let coordinates: CLLocationCoordinates?
    
    init(name: String, commentDict: [[String: String]], key: String = "", address: String, longitude: Double, latitude: Double) {
        self.ref = nil
        self.key = key
        self.name = name
        self.commentDict = commentDict
        self.address = address
        self.longitude = longitude
        self.latitude = latitude
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let commentDict = value["comment"] as? [[String: String]],
            let address = value["address"] as? String,
            let longitude = value["longitude"] as? Double,
            let latitude = value["latitude"] as? Double else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.commentDict = commentDict
        self.address = address
        self.longitude = longitude
        self.latitude = latitude
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "comment": commentDict,
            "address": address,
            "longitude": longitude,
            "latitude": latitude
        ]
    }
}

extension LocationObject {
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}
