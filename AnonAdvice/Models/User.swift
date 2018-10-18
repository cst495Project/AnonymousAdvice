//
//  User.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import Foundation

class User {
    var userID: String
    var username: String
    var timestamp: Double
    var good: Int
    var bad: Int
    
    init(userID: String, username: String,timestamp: Double, good: Int, bad: Int) {
        self.userID = userID
        self.username = username
        self.timestamp = timestamp
        self.good = good
        self.bad = bad
    }
}
