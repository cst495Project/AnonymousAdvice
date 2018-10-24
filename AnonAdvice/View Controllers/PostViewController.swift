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
    
    var postTitle: String?
    var postText: String?
    var postId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = postTitle
        textLabel.text = postText
    }
    
    @IBAction func onDelete(_ sender: Any) {
        //make the database deletion here
        let current = Auth.auth().currentUser!.uid
        let postRef = Database.database().reference().child("posts").child(postId!)
        postRef.removeValue() { error, completed  in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
        }
        
        performSegue(withIdentifier: "delete", sender: nil)
    }
    
}
