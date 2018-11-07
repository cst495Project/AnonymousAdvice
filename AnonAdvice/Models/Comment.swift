//
//  Comment.swift
//  AnonAdvice
//
//  Created by Devin Hight on 11/2/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import Foundation

class Comment {
    
    var id: String
    var author: String
    var text: String
    var timestamp: String
    
    init(id: String, author: String, text: String, timestamp: String) {
        self.id = id
        self.author = author
        self.text = text
        self.timestamp = timestamp
    }
    
}
