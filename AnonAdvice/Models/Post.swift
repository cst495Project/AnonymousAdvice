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
    var author: String
    var title: String
    var text: String
    var timestamp: String
    var subject: String
    var favorite: String
    var replyCount: Int
    
    init(id: String, author: String, title: String, text: String, timestamp: String, subject: String, favorite: String, replyCount: Int) {
        self.id = id
        self.author = author
        self.title = title
        self.text = text
        self.timestamp = timestamp
        self.subject = subject
        self.favorite = favorite
        self.replyCount = replyCount
    }
}
