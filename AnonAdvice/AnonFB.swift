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
                    //"username": email,
                    "city": city,
                    "timestamp": [".sv": "timestamp"],
                    "score": ["good": 0, "bad": 0] ] as [String: Any]
                self.usersRef.child(user!.user.uid).setValue(userObject)
                completionBlock(error)
            }else{
                print(error?.localizedDescription as Any)
                completionBlock(error)
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
                //let username = snap.childSnapshot(forPath: "username").value as? String ?? "No username"
                let timestamp = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                let good = snap.childSnapshot(forPath: "good").value as? Int ?? 0
                let bad = snap.childSnapshot(forPath: "bad").value as? Int ?? 0
                user = User.init(userID: userId, timestamp: timestamp, good: good, bad: bad)
                completionblock(user)
            } else {
                print("No author found")
            }
        }
    }
    // Retrieve all Posts created by a User as Post snapshot
    static func fetchUserPosts(_ userId: String!, completionblock: @escaping ((_ posts: [String])-> Void )) {
        var postIds: [String] = []
        let posts = usersRef.child(userId).child("posts")
        posts.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let postId = snap.key
                    postIds.append(postId)
                }
                let postIds = Array(Set(postIds)).sorted()
                completionblock(postIds)
            } else {
                print("No posts created by user")
            }
        }
    }
    // Retrieve all PostIds a User has replied to
    static func fetchUserRepliedPosts(_ userId: String!, completionblock: @escaping ((_ postIds: [String], _ replyIds:[String])-> Void )) {
        var postIds: [String] = []
        var replyIds: [String] = []
        let query = usersRef.child(userId).child("replies")
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let postId = snap.value as! String
                    postIds.append(postId)
                    replyIds.append(snap.key)
                }
                let postIds = Array(Set(postIds)).sorted()
                let replyIds = Array(Set(replyIds)).sorted()
                completionblock(postIds, replyIds)
            } else {
                print("No posts replied to")
            }
        })
    }
    // retrieve a User's total Advice Score (good and bad)
    static func fetchUserAdviceScore(_ userId: String!, completionblock: @escaping ((_ scores: [String: Int])-> Void )) {
        var scores = [ "good": 0, "bad": 0 ] as [String: Int]
        let scoreRef = usersRef.child(userId).child("score")
        scoreRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                scores["good"] = snapshot.childSnapshot(forPath: "good").value as? Int
                scores["bad"] = snapshot.childSnapshot(forPath: "bad").value as? Int
                completionblock(scores)
            } else {
                print("No data found")
            }
        }
    }
    // Retrieve all posts as snapshot
    static func fetchPostsData(completionblock: @escaping ((_ data: DataSnapshot)-> Void )) {
        postRef.queryLimited(toLast: 20).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completionblock(snapshot)
            } else {
                print("No posts found")
            }
        }
    }
    // Retrieve a Post Object from a postId
    static func fetchPost(_ postId: String!, completionblock: @escaping ((_ post: Post)-> Void )) {
        var post: Post!
        let singlePostRef = postRef.child(postId!)
        singlePostRef.observeSingleEvent(of: .value, with: { (snap) in
            if snap.exists() {
                let id = snap.key
                let author = snap.childSnapshot(forPath: "author").value as? String ?? "No author"
                let title = snap.childSnapshot(forPath: "title").value as? String ?? "No title"
                let text = snap.childSnapshot(forPath: "text").value as? String ?? "No text"
                let time = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                let date = Date(timeIntervalSince1970: time/1000)
                let subject = snap.childSnapshot(forPath: "subject").value as? String ?? "No subject"
                let timestamp = date.shortTimeAgoSinceNow + " ago"
                let favorite = snap.childSnapshot(forPath: "favorite").value as? String ?? "n/a"
                let replyCount = snap.childSnapshot(forPath: "count").value as? Int ?? 0
                post = Post.init(id: id, author: author, title: title, text: text, timestamp: timestamp, subject: subject, favorite: favorite, replyCount: replyCount)
                completionblock(post)
            } else {
                print("No post by that ID found")
            }
        })
    }
    // Retrieve all Local Posts as Post Snapshot
    static func fetchLocalPosts(_ currentCity: String!, completionblock: @escaping ((_ snapshot: DataSnapshot)-> Void )) {
        let query = postRef.queryOrdered(byChild: "city").queryEqual(toValue: currentCity).queryLimited(toLast: 20)
        query.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completionblock(snapshot)
            } else {
                completionblock(snapshot)
                print("No posts found")
            }
        }
    }
    
    static func fetchFilteredPosts(local: Bool, _ currentCity: String!,_ subject: String, completionblock: @escaping ((_ snapshot: [Post])-> Void )) {
        var posts: [Post] = []
        var returned: [Post] = []
        if local{
            AnonFB.fetchLocalPosts(currentCity) { (DataSnapshot) in
                AnonFB.getPostsInfo(DataSnapshot, completionblock: { (Post) in
                    posts = Post.reversed()
                    for posts in posts{
                        if posts.subject == subject{
                            returned.append(posts)
                        }
                    }
                    completionblock(returned)
                })
            }
        }else{
            AnonFB.fetchPostsData { (DataSnapshot) in
                AnonFB.getPostsInfo(DataSnapshot, completionblock: { (Post) in
                    posts = Post.reversed()
                    for posts in posts{
                        if posts.subject == subject{
                            returned.append(posts)
                        }
                    }
                    completionblock(returned)
                })
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
                let subject = snap.childSnapshot(forPath: "subject").value as? String ?? "No subject"
                let timestamp = date.shortTimeAgoSinceNow + " ago"
                let favorite = snap.childSnapshot(forPath: "favorite").value as? String ?? "n/a"
                let replyCount = snap.childSnapshot(forPath: "count").value as? Int ?? 0
                posts.append(Post.init(id: id, author: author, title: title, text: text, timestamp: timestamp, subject: subject, favorite: favorite, replyCount: replyCount))
            }
            completionblock(posts)
        } else {
            completionblock(posts)
            print("No posts found")
        }
    }
    // Delete a Post from Posts and User's list of Posts
    static func deletePost(_ postId: String!, completionblock: @escaping ((_ error: Error?)-> Void )) {
        let deleteRef = postRef.child(postId!)
        deleteRef.removeValue() { error, completed  in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                let current = Auth.auth().currentUser?.uid
                let user = usersRef.child(current!).child("posts").child(postId)
                user.removeValue()  { error, completed  in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    } else {
                        completionblock(error)
                    }
                }
            }
        }
    }
    // Delete a Reply from a Post
    static func deleteReply(_ postId: String!, replyId: String!, completionblock: @escaping ((_ error: Error?)-> Void )) {
        let deleteRef = postRef.child(postId!).child("replies").child(replyId!)
        deleteRef.removeValue() { error, completed  in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                let current = Auth.auth().currentUser?.uid
                let user = usersRef.child(current!).child("replies").child(replyId)
                user.removeValue()  { error, completed  in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    } else {
                        postRef.child(postId!).child("count").observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.exists() {
                                let count = snapshot.value as? Int
                                if count! > 0 {
                                    postRef.child(postId!).child("count").setValue(count! - 1)
                                }
                                completionblock(error)
                            }
                        })
                    }
                }
            }
        }
    }
    // Retrieve the number of replies of a post
    static func getReplyCount(_ postId: String!,  completionblock: @escaping ((_ count: UInt)-> Void )) {
        var count: UInt!
        let replyRef = postRef.child(postId!).child("replies")
        replyRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChildren() {
                count = snapshot.childrenCount
            } else {
                count = 0
                print("No replies found")
            }
            completionblock(count)
        })
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
                completionblock(replies)
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
    // Create a Comment on a Reply
    static func createComment(_ comment: String!, postId: String!, replyId: String!, completionblock: @escaping ((_ error: Error?)-> Void )) {
        let current = Auth.auth().currentUser!.uid
        let replyRef = postRef.child(postId!).child("replies").child(replyId).child("comments").childByAutoId()
        let commentObject = [
            "author": current,
            "text": comment,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]
        replyRef.setValue(commentObject, withCompletionBlock: { error, ref  in
            if error == nil {
                let user = usersRef.child(current).child("comments")
                user.child(replyRef.key!).setValue(comment)
                completionblock(error)
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
}
