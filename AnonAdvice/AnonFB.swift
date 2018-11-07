//
//  AnonFB.swift
//  AnonAdvice
//
//  Created by Devin Hight on 11/5/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import Foundation
import Firebase

//TODO:
//  Create delegate/protocol for showing alerts

class AnonFB {  // Singleton class for managing Firebase Events.
    
    static let anonRef = Database.database().reference()
    static let postRef = Database.database().reference().child("posts")
    static let usersRef = Database.database().reference().child("users")
    
    // Authenticate the user
    static func loginUser(_ email: String!, password: String, completionBlock: @escaping ((_ error: Error?)-> Void )) {
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                completionBlock(error)
            }
        })
    }
    // Authenticate new user and create a new Users value in the database
    static func signUpUser(_ email: String!, password: String, city:String!, completionBlock: @escaping ((_ error: Error?)-> Void )) {
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            if user != nil{
                let userObject = [
                    "username": email,
                    "city": city,
                    "timestamp": [".sv": "timestamp"],
                    "good": 0,
                    "bad": 0 ] as [String: Any]
                self.usersRef.child(user!.user.uid).setValue(userObject)
                completionBlock(error)
            }else{
                print(error?.localizedDescription as Any)
            }
        })
    }
    // Retrieve the current user's data as snapshot
    static func fetchCurrentUserData(_ currentId: String!, completionblock: @escaping ((_ data: DataSnapshot)-> Void )) {
        usersRef.child(currentId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completionblock(snapshot)
            } else {
                print("No user found")
            }
        }
    }
    // Retrieve all users as snapshot
    static func fetchUsersData(completionblock: @escaping ((_ data: DataSnapshot)-> Void )) {
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completionblock(snapshot)
            } else {
                print("No user found")
            }
        }
    }
    // Retrieve User information from Id as User Object
    static func fetchUserById(userId: String!, completionblock: @escaping ((_ user: User)-> Void )) {
        var user: User!
        self.usersRef.child(userId).observeSingleEvent(of: .value) { (snap) in
            if snap.exists(){
                let username = snap.childSnapshot(forPath: "username").value as? String ?? "No username"
                let timestamp = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                let good = snap.childSnapshot(forPath: "good").value as? Int ?? 0
                let bad = snap.childSnapshot(forPath: "bad").value as? Int ?? 0
                user = User.init(userID: userId, username: username, timestamp: timestamp, good: good, bad: bad)
                completionblock(user)
            } else {
                print("No author found")
            }
        }
    }
    // Retrieve all posts as snapshot
    static func fetchPostsData(completionblock: @escaping ((_ data: DataSnapshot)-> Void )) {
        postRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completionblock(snapshot)
            } else {
                print("No posts found")
            }
        }
    }
    // Retrieve all Local Posts as Post Objects
    static func fetchLocalPosts(_ currentCity: String!, completionblock: @escaping ((_ snapshot: DataSnapshot)-> Void )) {
        let query = usersRef.queryOrdered(byChild: "city").queryEqual(toValue: currentCity)
        query.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completionblock(snapshot)
            } else {
                print("No posts found")
            }
        }
    }
    // Turn posts Snapshot into Post Objects
    static func getPostsInfo(_ snapshot: DataSnapshot, completionblock: @escaping ((_ posts: [Post])-> Void )) {
        var posts: [Post] = []
        if snapshot.exists() {
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let id = snap.key
                let author = snap.childSnapshot(forPath: "author").value as? String ?? "No author"
                let title = snap.childSnapshot(forPath: "title").value as? String ?? "No title"
                let text = snap.childSnapshot(forPath: "text").value as? String ?? "No text"
                let time = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                let date = Date(timeIntervalSince1970: time/1000)
                let timestamp = date.shortTimeAgoSinceNow + " ago"
                posts.append(Post.init(id: id, author: author, title: title, text: text, timestamp: timestamp, subject: "world"))
            }
            completionblock(posts)
        } else {
            print("No posts found")
        }
    }
    // Retrieve replies of a post as Reply Objects
    static func fetchReplies(_ postId: String!, completionblock: @escaping ((_ replies: [Reply])-> Void )) {
        var replies: [Reply] = []
        let replyRef = postRef.child(postId!).child("replies")
        replyRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let id = snap.key
                    let author = snap.childSnapshot(forPath: "author").value as? String ?? ""
                    let text = snap.childSnapshot(forPath: "text").value as? String ?? "No text"
                    let time = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                    let date = Date(timeIntervalSince1970: time/1000)
                    let timestamp = date.shortTimeAgoSinceNow + " ago"
                    let comments = snap.childSnapshot(forPath: "comments")
                    let rated = snap.childSnapshot(forPath: "rated")
                    let scores = self.getRatings(ratings: rated)
                    let good = scores["good"] ?? 0
                    let bad = scores["bad"] ?? 0
                    replies.append(Reply.init(id: id, author: author, text: text, timestamp: timestamp, good: good, bad: bad, comments: comments))
                }
            } else {
                print("No replies found")
            }
        })
    }
    // Count the good and bad points of a rated Snapshot
    static func getRatings(ratings: DataSnapshot) -> [String: Int] {
        var scores = [ "good": 0, "bad": 0 ] as [String: Int]
        for child in ratings.children {
            let snap = child as! DataSnapshot
            if snap.value as? String == "good" {
                scores["good"] = scores["good"]! + 1
            } else {
                scores["bad"] = scores["bad"]! + 1
            }
        }
        return scores
    }
    // Retrieve Comment Objects of a Reply from Reply.comment snapshot
    static func getComments(commentSnap: DataSnapshot) -> [Comment] {
        var comments: [Comment] = []
        for child in commentSnap.children {
            let snap = child as! DataSnapshot
            let id = snap.key
            let author = snap.childSnapshot(forPath: "author").value as? String ?? ""
            let text = snap.childSnapshot(forPath: "text").value as? String ?? "No text"
            let time = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
            let date = Date(timeIntervalSince1970: time/1000)
            let timestamp = date.shortTimeAgoSinceNow + " ago"
            comments.append(Comment.init(id: id, author: author, text: text, timestamp: timestamp))
        }
        return comments
    }
    
}
