//
//  ProfileViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/29/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellTapped{
    
    // TODO:
    // Highlight a cell when post has been replied to
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goodLabel: UILabel!
    @IBOutlet weak var badLabel: UILabel!
    
    var posts: [Post] = []
    var currentUserPost: String!
    let postRef = Database.database().reference().child("posts")
    let userRef = Database.database().reference().child("users")
    let currentUser = Auth.auth().currentUser
    var userId: String!
    var postID: String!
    var selectedPostId: String!
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
    let theView = VerifyUserView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //theView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        emailLabel.text = currentUser?.email
        AnonFB.fetchUserAdviceScore(currentUser!.uid) { (scores) in
            self.goodLabel.text = String(scores["good"]!)
            self.badLabel.text = String(scores["bad"]!)
        }
        //blurLayout()
        //logInScreen()
        getUsersCity()
        getPosts()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostCell", for: indexPath) as! UserPostCell
        cell.titleLabel.text = posts[indexPath.row].title
        cell.postTextLabel.text = posts[indexPath.row].text
        cell.timestampLabel.text = posts[indexPath.row].timestamp
        AnonFB.getReplyCount(posts[indexPath.row].id, completionblock: { (count) in
            cell.replyLabel.text = "Replies: \(String(count))"
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        postID = posts[indexPath.row].id
        performSegue(withIdentifier: "userPost", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePost(indexPath: indexPath) {
                tableView.beginUpdates()
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "userPost") {
            let dest = segue.destination as! UINavigationController
            let pvc = dest.topViewController as! PostViewController
            pvc.postId = postID
        }
    }
    
    func getPosts() {
        let current = Auth.auth().currentUser!.uid
        AnonFB.fetchUserPosts(current) { (Post) in
            AnonFB.getPostsInfo(Post, completionblock: { (Post) in
                self.posts = Post.reversed()
                self.tableView.reloadData()
            })
        }
    }
    
    func deletePost(indexPath: IndexPath, completionblock: @escaping (()-> Void )) {
        let alert = SCLAlertView()
        alert.addButton("Delete") {
        let pid = self.posts[indexPath.row].id
        AnonFB.deletePost(pid, completionblock: { (Error) in
            if Error != nil {
            print(Error?.localizedDescription as Any)
            } else {
                let current = Auth.auth().currentUser?.uid
                let userRef = Database.database().reference().child("users").child(current!).child("posts").child(pid)
                    userRef.removeValue()  { error, completed  in
                        if error != nil {
                            print(error?.localizedDescription as Any)
                        } else {
                            completionblock()
                        }
                    }
                }
            })
        }
        alert.showWarning("Confirmation Needed", subTitle: "Are you sure you want to delete your post?")
    }
    
    func logInScreen(){
        view.addSubview(theView)
        theView.translatesAutoresizingMaskIntoConstraints = false
        theView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        theView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        theView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        theView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }

    func getUsersCity(){
        userRef.child((currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            self.cityLabel.text = snapshot.childSnapshot(forPath: "city").value as? String ?? "Unknown"
        }
    }
  
    func blurLayout(){
        view.addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    func tooManyWrongAttempts() {
        self.performSegue(withIdentifier: "tooManyWrongAttemptsLogOutSegue", sender: nil)
    }
    
    func successfullLogIn() {
        self.visualEffectView.effect = nil
    }
}
