//
//  HomeViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/22/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import DateToolsSwift
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let postRef = Database.database().reference().child("posts")
    let userRef = Database.database().reference().child("users")
    let currentUser = Auth.auth().currentUser?.uid
    var currentUserCity: String!
    var posts: [Post] = []
    var postID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        getUsersCity()
        fetchLocalPosts()
        
        indexChange()
        segmentedControl.addTarget(self, action: #selector(indexChange), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    func getUsersCity(){
        userRef.child(currentUser!).observeSingleEvent(of: .value) { (snapshot) in
            self.currentUserCity = (snapshot.childSnapshot(forPath: "city").value as! String)
        }
    }

    
    @IBAction func onCompose(_ sender: Any) {
        self.performSegue(withIdentifier: "composeSegue", sender: self)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.titleLabel.text = posts[indexPath.row].title
        cell.postTextLabel.text = posts[indexPath.row].text
        cell.timestampLabel.text = "\(String(describing: posts[indexPath.row].timestamp))"
        return cell
    }
    
    func fetchWorldPosts(){
        var np: [Post] = []
        postRef.observe(.value) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                
                let id = snap.key
                let author = User.init(userID: "asd", username: "sd", timestamp: 5.5, good: 0, bad: 0)
                
                let title = snap.childSnapshot(forPath: "title").value as? String ?? "No title"
                let text = snap.childSnapshot(forPath: "text").value as? String ?? "No text"
                
                let time = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                let date = Date(timeIntervalSince1970: time/1000)
                let timestamp = date.shortTimeAgoSinceNow + " ago"
               
                np.append(Post.init(id: id, author: author, title: title, text: text, timestamp: timestamp, subject: "local"))
                
            }
            self.posts = np.reversed()
            self.tableView.reloadData()
        }
    }
    
    func fetchLocalPosts(){
        var newPosts: [Post] = []
        postRef.observe(.value) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let postCity = snap.childSnapshot(forPath: "city").value as? String ?? "Unknown"
                if(postCity == self.currentUserCity){
                    let id = snap.key
                    let author = User.init(userID: "asd", username: "sd", timestamp: 5.5, good: 0, bad: 0)
                    
                    let title = snap.childSnapshot(forPath: "title").value as? String ?? "No title"
                    let text = snap.childSnapshot(forPath: "text").value as? String ?? "No text"
                    
                    let time = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                    let date = Date(timeIntervalSince1970: time/1000)
                    let timestamp = date.shortTimeAgoSinceNow + " ago"
                    
                    newPosts.append(Post.init(id: id, author: author, title: title, text: text, timestamp: timestamp, subject: "local"))
                }
            }
            self.posts = newPosts.reversed()
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        postID = posts[indexPath.row].id
        performSegue(withIdentifier: "reply", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "reply") {
            let dest = segue.destination as! UINavigationController
            let pvc = dest.topViewController as! PostViewController
            pvc.postId = postID
        }
    }
    
    
    @objc func indexChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            localSelected()
        case 1:
            worldSelected()
        default:
            break;
        }
    }
    
    func localSelected(){
        //functionality for local tab
        fetchLocalPosts()
    }
    
    func worldSelected() {
        //functionality for world
        fetchWorldPosts()
    }

}
