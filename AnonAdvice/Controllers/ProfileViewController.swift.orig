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
import LocalAuthentication
import LocalAuthentication

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
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
    var wrongAttempts = 2
    let localAuthenticationContext = LAContext()
    var authError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
=======
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        emailTextField.text = currentUser?.email
        emailLabel.text = Auth.auth().currentUser?.email
        
       
>>>>>>> master
        getUsersCity()
        getPosts()
        blurLayout()
        isBiometricsSetUp()
<<<<<<< HEAD
        logInScreen()
    }
    
    func logInScreen(){
        view.addSubview(theView)
        theView.translatesAutoresizingMaskIntoConstraints = false
        theView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        theView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        theView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        theView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        theView.verifyButton.addTarget(self, action: #selector(verifyUser), for: .touchUpInside)
=======
        
        
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
    
    
    func getUsersCity(){
        userRef.child((currentUser?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            self.cityLabel.text = snapshot.childSnapshot(forPath: "city").value as? String ?? "Unknown"
        }
>>>>>>> master
    }
    
    
    func isBiometricsSetUp(){
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
<<<<<<< HEAD
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "I need your fingerprint") {
=======
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "reasonString") {
>>>>>>> master
                success, evaluateError in
                if success{
                    DispatchQueue.main.async {
                        self.theView.removeFromSuperview()
                        self.visualEffectView.effect = nil
                    }
                }
            }
        }
    }
    
    @objc func verifyUser(){
        let password = theView.passwordTextField.text
        
        Auth.auth().signIn(withEmail: self.currentUser!.email!, password: password!) { (authData: AuthDataResult?, error: Error?) in
            if authData != nil{
<<<<<<< HEAD
                self.visualEffectView.effect = nil
                self.theView.removeFromSuperview()
            }else{
                self.theView.errorMessageLabel.isHidden = false
                self.theView.errorMessageLabel.text = error?.localizedDescription ?? "Unknown error"
=======
                self.popUpView.removeFromSuperview()
                self.visualEffectView.effect = nil
                return
            }else{
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = error?.localizedDescription ?? "Unknown error"
>>>>>>> master
                self.wrongAttempts -= 1
            }
        }
        
        if wrongAttempts == 0 {
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError.localizedDescription)
            }
            self.performSegue(withIdentifier: "tooManyWrongAttemptsLogOutSegue", sender: nil)
        }
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
}

