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

class ProfileViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
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
        getUsersCity()
        blurLayout()
        isBiometricsSetUp()
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
    }
    
    func isBiometricsSetUp(){
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "I need your fingerprint") {
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
                self.visualEffectView.effect = nil
                self.theView.removeFromSuperview()
            }else{
                self.theView.errorMessageLabel.isHidden = false
                self.theView.errorMessageLabel.text = error?.localizedDescription ?? "Unknown error"
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
