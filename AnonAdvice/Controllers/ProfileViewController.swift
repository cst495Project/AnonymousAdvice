//
//  ProfileViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/29/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellTapped {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var posts: [Post] = []
    var currentUserPost: String!
    let postRef = Database.database().reference().child("posts")
    let userRef = Database.database().reference().child("users")
    let currentUser = Auth.auth().currentUser
    var userId: String!
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
    let theView = VerifyUserView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        emailLabel.text = currentUser?.email
       
        getUsersCity()
        getPosts()
        blurLayout()
        logInScreen()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.titleLabel.text = posts[indexPath.row].title
        cell.postTextLabel.text = posts[indexPath.row].text
        
        return cell
    }
    
    func getPosts() {
        let current = Auth.auth().currentUser!.uid
        AnonFB.fetchUserPosts(userId: current) { (Post) in
            self.posts = Post
            print(self.posts)
            self.tableView.reloadData()
        }
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
