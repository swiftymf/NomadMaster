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
    var name: String
    var comment: [[String: String]]  // Change to dictionary? [username: comment]
    var address: String

    // TODO: - Add these properties
//    let coordinates: CLLocationCoordinates?
    
    init(name: String, comment: [[String: String]], key: String = "", address: String) {
        self.ref = nil
        self.key = key
        self.name = name
        self.comment = comment
        self.address = address
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            var comment = value["comment"] as? [[String: String]],
            var address = value["address"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.comment = comment
        self.address = address
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "comment": comment,
            "address": address
        ]
    }
}

