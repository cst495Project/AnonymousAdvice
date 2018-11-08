//
//  ProfileViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/29/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
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
    var wrongAttempts = 2
    let localAuthenticationContext = LAContext()
    var authError: NSError?
    
    let popUpView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = #colorLiteral(red: 0.9689862651, green: 0.9689862651, blue: 0.9689862651, alpha: 1)
        return v
    }()
    let emailTextField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .white
        t.autocapitalizationType = .none
        t.isUserInteractionEnabled = false
        return t
    }()
    
    let passwordTextField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.placeholder = "Password"
        t.backgroundColor = .white
        t.isSecureTextEntry = true
        t.autocapitalizationType = .none
        return t
    }()
    
    let verifyLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        l.text = "We need to verify it is actually you"
        return l
    }()
    
    let verifyButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        b.setTitle("Verify", for: .normal)
        b.addTarget(self, action: #selector(verifyUser), for: .touchUpInside)
        return b
    }()
    
    let errorMessageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        l.textColor = .red
        l.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        l.numberOfLines = 0
        return l
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        emailTextField.text = currentUser?.email
        emailLabel.text = Auth.auth().currentUser?.email
        
       
        getUsersCity()
        getPosts()
        blurLayout()
        logInPopUp()
        isBiometricsSetUp()
        
        
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
    }
    
    
    func isBiometricsSetUp(){
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "reasonString") {
                success, evaluateError in
                if success{
                    DispatchQueue.main.async {
                        self.visualEffectView.effect = nil
                        self.popUpView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    @objc func verifyUser(){
        let password = passwordTextField.text
        
        Auth.auth().signIn(withEmail: self.currentUser!.email!, password: password!) { (authData: AuthDataResult?, error: Error?) in
            if authData != nil{
                self.popUpView.removeFromSuperview()
                self.visualEffectView.effect = nil
                return
            }else{
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = error?.localizedDescription ?? "Unknown error"
                self.wrongAttempts -= 1
            }
        }
        
        if wrongAttempts == 0{
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError.localizedDescription)
            }
            self.performSegue(withIdentifier: "tooManyWrongAttemptsLogOutSegue", sender: nil)
        }
    }
    
    func logInPopUp(){
        view.addSubview(popUpView)
        popUpView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        popUpView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        popUpView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        popUpView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        popUpView.addSubview(verifyLabel)
        verifyLabel.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 20).isActive = true
        verifyLabel.widthAnchor.constraint(equalTo: popUpView.widthAnchor, multiplier: 0.9).isActive = true
        verifyLabel.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        verifyLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        popUpView.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(greaterThanOrEqualTo: verifyLabel.bottomAnchor, constant: 20).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: popUpView.widthAnchor, multiplier: 0.9).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        popUpView.addSubview(errorMessageLabel)
        errorMessageLabel.topAnchor.constraint(equalTo: verifyLabel.bottomAnchor).isActive = true
        errorMessageLabel.widthAnchor.constraint(equalTo: popUpView.widthAnchor, multiplier: 0.9).isActive = true
        errorMessageLabel.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        errorMessageLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor).isActive = true
        
        popUpView.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: popUpView.widthAnchor, multiplier: 0.9).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        popUpView.addSubview(verifyButton)
        verifyButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        verifyButton.widthAnchor.constraint(equalTo: popUpView.widthAnchor, multiplier: 0.9).isActive = true
        verifyButton.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor).isActive = true
        verifyButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
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

