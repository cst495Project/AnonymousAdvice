//
//  PostViewController.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/18/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import DateToolsSwift
import SCLAlertView

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //TODO:
    //      add select cell to view more replies
    //      add a tap author's text to expand? (maybe with a view animation)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var postId: String?
    var replies: [Reply] = []
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        
        refreshControl.addTarget(self, action: #selector(PostViewController.didPullToRefresh(_ :)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        activityIndicator.startAnimating()
        
        getPost()
        getPostReplies()
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl)
    {
        activityIndicator.startAnimating()
        getPostReplies()
    }
    
    func getPost() {
        let current = Auth.auth().currentUser!.uid
        let postRef = Database.database().reference().child("posts").child(postId!)
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let author = value!["author"]! as? String ?? ""
            self.titleLabel.text = value?["title"] as? String ?? ""
            self.textLabel.text = value?["text"] as? String ?? ""
            if current == author {
                self.rightButton.setTitle("Delete", for: .normal)
                self.navBar.title = "Your Post"
            } else {
                self.rightButton.setTitle("Reply", for: .normal)
                self.navBar.title = "Post"
            }
        })
    }
    
    func getPostReplies() {
        var nr: [Reply] = []
        let postRef = Database.database().reference().child("posts").child(postId!).child("replies")
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let id = snap.key
                let author = snap.childSnapshot(forPath: "author").value as? String ?? ""
                let text = snap.childSnapshot(forPath: "text").value as? String ?? "No text"
                let time = snap.childSnapshot(forPath: "timestamp").value as? Double ?? 1
                let date = Date(timeIntervalSince1970: time/1000)
                let timestamp = date.shortTimeAgoSinceNow + " ago"
                let good = snap.childSnapshot(forPath: "good").value as? Int ?? 0
                let bad = snap.childSnapshot(forPath: "bad").value as? Int ?? 0
                nr.append(Reply.init(id: id, author: author, text: text, timestamp: timestamp, good: good, bad: bad))
            }
            self.replies = nr
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyCell
        cell.replyTextLabel.text = replies[indexPath.row].text
        cell.timestampLabel.text = "\(String(describing: replies[indexPath.row].timestamp))"
        cell.goodPoints.text = String(replies[indexPath.row].good)
        cell.badPoints.text = String(replies[indexPath.row].bad)
        cell.reply = replies[indexPath.row]
        cell.postId = postId
        return cell
    }

    @IBAction func onHome(_ sender: Any) {
        performSegue(withIdentifier: "home", sender: nil)
    }
    
    @IBAction func onRightButton(_ sender: UIButton) {
        let postRef = Database.database().reference().child("posts").child(postId!)
        if sender.title(for: .normal) == "Delete" {
            //get confirmation here
            postRef.removeValue() { error, completed  in
                if error != nil {
                    print("Error occured:")
                    print(error?.localizedDescription as Any)
                    //show alert dialogue
                } else {
                    self.performSegue(withIdentifier: "home", sender: self)
                }
            }
        } else {
            performSegue(withIdentifier: "createReply", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "createReply") {
            let rvc = segue.destination as! ReplyViewController
            rvc.postID = postId
            rvc.parentTitle = titleLabel.text
            rvc.parentText = textLabel.text
        }
    }
    
}
