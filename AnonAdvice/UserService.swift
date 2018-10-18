//
//  UserService.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import Foundation
//import Firebase
//
//class UserService {
//
//    static var currentUser: User?
//
//    static func observeUserProfile(_ userID: String, completion:@escaping ((_ User: User?)->())) {
//        let userRef = Database.database().reference().child("users/\(userID)")
//        userRef.observe(.value, with: { snapshot in
//            var user: User?
//            if let dict = snapshot.value as? [String: Any],
//                let username = dict["username"] as? String,
//                let timestamp = dict["timestamp"] as? Double,
//                let good = dict["good"] as? Int,
//                let bad = dict["bad"] as? Int {
//                user = User(userID: userID, username: username, timestamp: timestamp, good: good, bad: bad)
//            }
//            completion(user)
//        })
//    }
//
//}
