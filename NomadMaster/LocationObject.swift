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
    let comment: String
    let addedByUser: String
    
    init(name: String, comment: String, addedByUser: String, key: String = "") {
        self.ref = nil
        self.key = key
        self.name = name
        self.comment = comment
        self.addedByUser = addedByUser
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let comment = value["comment"] as? String,
            let addedByUser = value["addedByUser"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.comment = comment
        self.addedByUser = addedByUser
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "comment": comment,
            "addedByUser": addedByUser
        ]
    }
}
