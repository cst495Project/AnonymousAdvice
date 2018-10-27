//
//  PostViewController.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/18/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var postId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPost()
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
        let postRef = Database.database().reference().child("posts").child(postId!)
        postRef.observe(DataEventType.value, with: { (snapshot) in
            let replyDict = snapshot.value as? [String : Any] ?? [:]
            //get replies to populate table view
        })
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
            //reply to post
            print("we are going to reply now..")
        }
    }
    
}
