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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var changeCity: UIButton!
    @IBOutlet weak var nightButton: UIButton!
    
    var posts: [Post] = []
    var usersPosts: [Post] = []
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
    let defaults = UserDefaults.standard
    var currentSegment: Int! = 0
    var repliedPostsString: [String] = []
    var replies: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = currentUser?.email
        emailLabel.isHidden = true
        
        emailLabel.mixedTextColor = MixedColor(normal: emailLabel.textColor ?? .black, night: .white)
        emailField.isHidden=true
        emailField.mixedTextColor = MixedColor(normal: emailField.textColor ?? .black, night: .white)
        cityField.isHidden=true
        cityField.mixedTextColor = MixedColor(normal: cityField.textColor ?? .black, night: .white)
        advicePointsField.isHidden=true
        advicePointsField.mixedTextColor = MixedColor(normal: advicePointsField.textColor ?? .black, night: .white)
        goodLabel.isHidden = true
        badLabel.isHidden = true
        cityLabel.isHidden = true
        cityLabel.mixedTextColor = MixedColor(normal: cityLabel.textColor ?? .black, night: .white)
        segmentedControl.isHidden = true
        
        changeCity.isHidden = true
        nightButton.isHidden = true
        emailLabel.text = currentUser?.email
        emailLabel.mixedTextColor = MixedColor(normal: emailLabel.textColor ?? .black, night: .white)
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mixedBackgroundColor = MixedColor(normal: tableView.backgroundColor ?? .white, night: .black)
        
        verifyUserView.delegate = self
        
        segmentedControl.addTarget(self, action: #selector(indexChange), for: .valueChanged)
        
        checkIfVerified()
        
        thisView.mixedBackgroundColor = MixedColor(normal: thisView.backgroundColor ?? .white, night: .black)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostCell", for: indexPath) as! UserPostCell
        cell.titleLabel.text = posts[indexPath.row].title
        cell.postTextLabel.text = posts[indexPath.row].text
        cell.timestampLabel.text = posts[indexPath.row].timestamp
        cell.replyLabel.text = "Replies: \(String(posts[indexPath.row].replyCount))"
        
        cell.titleLabel.mixedTextColor = MixedColor(normal: cell.titleLabel.textColor ?? .black, night: .white)
        cell.postTextLabel.mixedTextColor = MixedColor(normal: cell.postTextLabel.textColor ?? .black, night: .white)
        cell.mixedBackgroundColor = MixedColor(normal: cell.backgroundColor ?? .white, night: .black)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        postID = posts[indexPath.row].id
        performSegue(withIdentifier: "userPost", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return currentSegment == 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePost(indexPath: indexPath) {_ in 
                tableView.beginUpdates()
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "userPost") {
            let dest = segue.destination as! UINavigationController
            let pvc = dest.topViewController as! PostViewController
            pvc.postId = postID
            pvc.sourceView = "Profile"
        }
    }
    
    func fetchUserPosts() {
        AnonFB.fetchUserPosts(current) { (Posts) in
            if !Posts.isEmpty {
                for postId in Posts {
                    AnonFB.fetchPost(postId, completionblock: { (Post) in
                        self.usersPosts.append(Post)
                    })
                }
            }
        }
    }
    
    func fetchUsersPosts() {
        self.posts = usersPosts
        self.tableView.reloadData()
    }
    
    func fetchRepliedPosts() {
        AnonFB.fetchUserRepliedPosts(current) { (Posts, Replies) in
            if !Posts.isEmpty {
                self.repliedPostsString = Posts
                self.replies = Replies
                for postId in Posts {
                    AnonFB.fetchPost(postId, completionblock: { (Post) in
                        self.repliedPosts.append(Post)
                    })
                }
            }
        }
    }
    
    func fetchUserRepliedPosts() {
        self.posts = repliedPosts.reversed()
        self.tableView.reloadData()
    }
    
    func removeOldRepliedPosts() {
        var realPosts: [String] = []
        for post in repliedPosts{
            realPosts.append(post.id)
        }
        let set1 = Set(realPosts)
        let difference = Array(set1.symmetricDifference(repliedPostsString))
        for post in difference {
            let indexOfPost = repliedPostsString.index(of: post)
            let reply = replies[indexOfPost!]
            let user = Database.database().reference().child("users").child(current).child("replies").child(reply)
            user.removeValue()  { error, completed  in
                if error != nil {
                    print(error?.localizedDescription as Any)
                } else {
                    print("Unused data deleted")
                }
            }
        }
    }
    
    func deletePost(indexPath: IndexPath, completionblock: @escaping ((Error?)-> Void )) {
        let alert = SCLAlertView()
        alert.addButton("Delete") {
            let pid = self.posts[indexPath.row].id
            AnonFB.deletePost(pid, completionblock: { (Error) in
                if Error != nil {
                    print(Error?.localizedDescription as Any)
                } else {
                    self.tableView.reloadData()
                    completionblock(Error)
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
        goodLabel.isHidden = false
        badLabel.isHidden = false
        segmentedControl.isHidden = false
        changeCity.isHidden = false
        nightButton.isHidden = false
        nightButton.imageView?.contentMode = .scaleAspectFit
        getUsersCity()
        fetchUserPosts()
        fetchRepliedPosts()
        AnonFB.fetchUserAdviceScore(currentUser!.uid) { (scores) in
            self.goodLabel.text = "Good: \(self.abbreviate(num: scores["good"] ?? 0))"
            self.badLabel.text = "Bad: \(self.abbreviate(num: scores["bad"] ?? 0))"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchUsersPosts()
            self.removeOldRepliedPosts()
        }
        defaults.set(true, forKey: "verified")
        defaults.synchronize()
    }
    
    func abbreviate(num: Int) -> String {
        var n = Double(num)
        if num >= 1000 && num < 1000000 {
            n = Double( floor(n/100)/10 )
            return "\(n.description)K"
        } else if num >= 1000000 {
            n = Double( floor(n/100000)/10 )
            return "\(n.description)M"
        }
        return "\(num)"
    }
    
    @objc func indexChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            fetchUsersPosts()
            currentSegment = 0
        case 1:
            fetchUserRepliedPosts()
            currentSegment = 1
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
        userRef.child(self.current).child("city").setValue(cityLabel.text)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNightButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        if (NightNight.theme == .night) {
            DispatchQueue.main.async {
                NightNight.theme = .normal
                print("normal")
            }
        } else {
            DispatchQueue.main.async {
                NightNight.theme = .night
                print("night")
            }
            
        }
    }
    
    func checkIfVerified(){
        let isVerified = UserDefaults.standard.bool(forKey: "verified")
        if !isVerified{
            logInScreen()
        }else{
            successfullLogIn()
        }
    }
}
