//
//  Reply.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/27/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import Foundation

class Reply {
    var id: String
    var author: String
    var text: String
    var timestamp: String
    var good: Int
    var bad: Int
    
    init(id: String, author: String, text: String, timestamp: String, good: Int, bad: Int) {
        self.id = id
        self.author = author
        self.text = text
        self.timestamp = timestamp
        self.good = good
        self.bad = bad
    }
}
