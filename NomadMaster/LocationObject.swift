//
//  LocationObject.swift
//  NomadMaster
//
//  Created by Markith on 8/7/19.
//  Copyright © 2019 Markith. All rights reserved.
//

import Foundation
import Firebase

struct LocationObject {
    
    let ref: DatabaseReference?
    let key: String
    let name: String
    let comment: [String]  // Change to dictionary? [username: comment]
    let addedByUser: String
    let address: String

    // TODO: - Add these properties
//    let coordinates: CLLocationCoordinates?
    
    init(name: String, comment: [String], addedByUser: String, key: String = "", address: String) {
        self.ref = nil
        self.key = key
        self.name = name
        self.comment = comment
        self.addedByUser = addedByUser
        self.address = address
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let comment = value["comment"] as? [String],
            let addedByUser = value["addedByUser"] as? String,
            let address = value["address"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.comment = comment
        self.addedByUser = addedByUser
        self.address = address
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "comment": [comment],
            "addedByUser": addedByUser,
            "address": address
        ]
    }
}
