//
//  Comment.swift
//  NomadMaster
//
//  Created by Markith on 8/11/19.
//  Copyright © 2019 Markith. All rights reserved.
//

import Foundation
import Firebase

struct Comment {
    let timeStamp: String
    let userComment: String
    let username: String
}

extension Comment {
    init(comment: Dictionary<String, String>){
        timeStamp = comment["timeStamp"] ?? ""
        userComment = comment["comment"] ?? ""
        username = comment["username"] ?? ""
    }
}



//struct Comment {
//    let ref: DatabaseReference?
//    let key: String
//    let timeStamp: String
//    let comment: String
//    let username: String
//
//    init(key: String = "", timeStamp: String, comment: String, username: String) {
//        self.ref = nil
//        self.key = key
//        self.timeStamp = timeStamp
//        self.comment = comment
//        self.username = username
//    }
//
//    init?(snapshot: DataSnapshot) {
//        guard
//            let value = snapshot.value as? [String: AnyObject],
//            let timeStamp = value["timeStamp"] as? String,
//            let comment = value["comment"] as? String,
//            let username = value["username"] as? String else {
//                return nil
//        }
//
//        self.ref = snapshot.ref
//        self.key = snapshot.key
//        self.timeStamp = timeStamp
//        self.comment = comment
//        self.username = username
//    }
//
//    func toAnyObject() -> Any {
//        return [
//            "timeStamp": timeStamp,
//            "comment": comment,
//            "username": username
//        ]
//    }
//}
