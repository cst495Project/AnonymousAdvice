//
//  ProfileViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/29/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GooglePlacePicker
import SCLAlertView
import NightNight

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LogInAttemptDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goodLabel: UILabel!
    @IBOutlet weak var badLabel: UILabel!
    @IBOutlet var thisView: UIView!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var cityField: UILabel!
    @IBOutlet weak var advicePointsField: UILabel!
    @IBOutlet weak var imageViewField: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var posts: [Post] = []
    var repliedPosts: [Post] = []
    var currentUserPost: String!
    let postRef = Database.database().reference().child("posts")
    let userRef = Database.database().reference().child("users")
    let currentUser = Auth.auth().currentUser
    let current = Auth.auth().currentUser!.uid
    var userId: String!
    var postID: String!
    var selectedPostId: String!
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
    let verifyUserView = VerifyUserView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = currentUser?.email
        emailLabel.isHidden = true
        
        emailField.isHidden=true
        cityField.isHidden=true
        advicePointsField.isHidden=true
        imageViewField.isHidden = true
        goodLabel.isHidden = true
        badLabel.isHidden = true
        cityLabel.isHidden = true
        segmentedControl.isHidden = true
        emailLabel.text = currentUser?.email
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        verifyUserView.delegate = self
        
        segmentedControl.addTarget(self, action: #selector(indexChange), for: .valueChanged)
        
        logInScreen()
        thisView.mixedBackgroundColor = MixedColor(normal: 0xf0f0f0, night: 0x800f0f)
        
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
    
    func fetchUserPosts() {
        AnonFB.fetchUserPosts(current) { (Post) in
            AnonFB.getPostsInfo(Post, completionblock: { (Post) in
                self.posts = Post.reversed()
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchRepliedPosts() {
        AnonFB.fetchUserRepliedPosts(current) { (Posts) in
            for postId in Posts {
                AnonFB.fetchPost(postId, completionblock: { (Post) in
                    self.repliedPosts.append(Post)
                })
            }
        }
    }
    
    func fetchUserRepliedPosts() {
        self.posts = repliedPosts
        self.tableView.reloadData()
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
        view.addSubview(verifyUserView)
        verifyUserView.translatesAutoresizingMaskIntoConstraints = false
        verifyUserView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        verifyUserView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        verifyUserView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        verifyUserView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }

    func getUsersCity(){
        userRef.child((currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            self.cityLabel.text = snapshot.childSnapshot(forPath: "city").value as? String ?? "Unknown"
        }
    }
      
    func tooManyWrongAttempts() {
        self.performSegue(withIdentifier: "tooManyWrongAttemptsLogOutSegue", sender: nil)
    }
    
    func successfullLogIn() {
        self.visualEffectView.effect = nil
        tableView.isHidden = false
        emailLabel.isHidden = false
        cityLabel.isHidden = false
        emailField.isHidden = false
        cityField.isHidden = false
        advicePointsField.isHidden = false
        imageViewField.isHidden = false
        goodLabel.isHidden = false
        badLabel.isHidden = false
        segmentedControl.isHidden = false
        getUsersCity()
        fetchUserPosts()
        fetchRepliedPosts()
        AnonFB.fetchUserAdviceScore(currentUser!.uid) { (scores) in
            self.goodLabel.text = String(scores["good"] ?? 0)
            self.badLabel.text = String(scores["bad"] ?? 0)
        }
    }
    
    @objc func indexChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            fetchUserPosts()
        case 1:
            fetchUserRepliedPosts()
        default:
            break;
        }
    }
    
    @IBAction func onChangeLocation(_ sender: Any) {
        let placePicker = GMSAutocompleteViewController()
        placePicker.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment  //suitable filter type
        filter.type = .city
        placePicker.autocompleteFilter = filter
        
        present(placePicker, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        cityLabel.text = place.formattedAddress!
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNightButton(_ sender: Any) {
        if(NightNight.theme == .night){
            NightNight.theme = .normal
            print("normal")
        }
        else{
            NightNight.theme = .night
            print("night")
        }
        
    }
}
