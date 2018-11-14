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
import NightNight

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var thisView: UIView!
    
    let postRef = Database.database().reference().child("posts")
    let userRef = Database.database().reference().child("users")
    let currentUser = Auth.auth().currentUser?.uid
    var currentUserCity: String!
    var posts: [Post] = []
    var postID: String?
    var refreshControl = UIRefreshControl()
    let subjectSelector = SubjectSelector()
    
    let filterButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Filter", for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.addTarget(self, action: #selector(fetchFilteredPosts), for: .touchUpInside)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        
        segmentedControl.addTarget(self, action: #selector(fetchFilteredPosts), for: .valueChanged)
        refreshControl.addTarget(self, action: #selector(HomeViewController.didPullToRefresh(_ :)), for: .valueChanged)
        
        getUsersCity()
        setUpView()

        tableView.insertSubview(refreshControl, at: 0)
        activityIndicator.startAnimating()
        
        thisView.mixedBackgroundColor = MixedColor(normal: 0xf0f0f0, night: 0x800f0f)
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        activityIndicator.startAnimating()
        indexChange()
    }
    
    func getUsersCity(){
        userRef.child(currentUser!).observeSingleEvent(of: .value) { (snapshot) in
            self.currentUserCity = (snapshot.childSnapshot(forPath: "city").value as? String ?? "")
            self.fetchFilteredPosts()
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
    
    func fetchWorldPosts() {
        AnonFB.fetchPostsData { (snapshot) in
            AnonFB.getPostsInfo(snapshot, completionblock: { (Post) in
                self.posts = Post.reversed()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    func fetchLocalPosts(){
        AnonFB.fetchLocalPosts(self.currentUserCity) { (snapshot) in
            AnonFB.getPostsInfo(snapshot, completionblock: { (Post) in
                self.posts = Post.reversed()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    @objc func fetchFilteredPosts(){
        if subjectSelector.currentSelectedSubject() == "All"{
            indexChange()
            return
        }
        if segmentedControl.selectedSegmentIndex == 0{
            AnonFB.fetchFilteredPosts(local: true ,self.currentUserCity, subjectSelector.currentSelectedSubject()) { (Post) in
                self.posts = Post
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            }
        }else{
            AnonFB.fetchFilteredPosts(local: false ,self.currentUserCity, subjectSelector.currentSelectedSubject()) { (Post) in
                self.posts = Post
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            }
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
    
    func indexChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            fetchLocalPosts()
        case 1:
            fetchWorldPosts()
        default:
            break;
        }
    }
    
    fileprivate func setUpView(){
        view.addSubview(subjectSelector)
        subjectSelector.translatesAutoresizingMaskIntoConstraints = false
        subjectSelector.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8).isActive = true
        subjectSelector.heightAnchor.constraint(equalToConstant: 30).isActive = true
        subjectSelector.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        subjectSelector.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7).isActive = true
        
        view.addSubview(filterButton)
        filterButton.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        filterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        filterButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2).isActive = true
    }

}
