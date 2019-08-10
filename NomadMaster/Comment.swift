//
//  Comment.swift
//  NomadMaster
//
//  Created by Markith on 8/10/19.
//  Copyright © 2019 Markith. All rights reserved.
//

import Foundation

struct Comment {
    var comment: String
    var user: String
    
    init(comment: String, user: String) {
        self.comment = comment
        self.user = user
    }
}
