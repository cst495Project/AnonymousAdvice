//
//  Post.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import Foundation

class Post {
    var id: String
    var author: User
    var title: String
    var text: String
    var timestamp: Double
    var subject: String
    //var location
    
    init(id: String, author: User, title: String, text: String, timestamp: Double, subject: String) {
        self.id = id
        self.author = author
        self.title = title
        self.text = text
        self.timestamp = timestamp
        self.subject = subject
    }
}
