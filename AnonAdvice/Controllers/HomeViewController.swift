//
//  HomeViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/22/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let postRef = Database.database().reference().child("posts")
    var posts: [Post] = []
    var postID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchWorldPosts()
        
        indexChange()
        segmentedControl.addTarget(self, action: #selector(indexChange), for: .valueChanged)
        // Do any additional setup after loading the view.
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
                np.append(Post.init(id: "12", author: User.init(userID: "asd", username: "sd", timestamp: 5.5, good: 0, bad: 0), title: snap.childSnapshot(forPath: "title").value as! String, text: snap.childSnapshot(forPath: "text").value as! String, timestamp: 5, subject: "local"))
            }
            self.posts = np.reversed()
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        fetchWorldPosts()
    }
    
    func worldSelected() {
        //functionality for world
        fetchWorldPosts()
    }

}
