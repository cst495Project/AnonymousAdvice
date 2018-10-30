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

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var postId: String?
    var replies: [Reply] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        getPost()
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
                self.replies.append(Reply.init(id: id, author: author, text: text, timestamp: timestamp))
            }
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyCell
        cell.replyTextLabel.text = replies[indexPath.row].text
        cell.timestampLabel.text = "\(String(describing: replies[indexPath.row].timestamp))"
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
