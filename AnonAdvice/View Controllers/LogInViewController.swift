//
//  LogInViewController.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    @IBOutlet weak var logInSignUpSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var logInSignUpButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        layout()
        logInSignUpSegmentedControl.addTarget(self, action: #selector(layout), for: .valueChanged)
        
        confirmPasswordTextField.isSecureTextEntry = true
        passwordTextField.isSecureTextEntry = true
        errorMessageLabel.isHidden = true
    }
    
    @objc func layout(){
        switch logInSignUpSegmentedControl.selectedSegmentIndex {
        case 0:
            logIn()
        case 1:
            signUp()
        default:
            logIn()
        }
    }
    
    func logIn(){
        confirmPasswordTextField.isHidden = true
        logInSignUpButton.setTitle("Log In", for: .normal)
    }
    
    func signUp(){
        confirmPasswordTextField.isHidden = false
        logInSignUpButton.setTitle("Sign Up", for: .normal)
    }
    
    @IBAction func onLogInSignUp(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if logInSignUpButton.currentTitle == "Log In"{
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if user != nil{
                    self.performSegue(withIdentifier: "logInSegue", sender: self)
                }else{
                    self.errorMessageLabel.isHidden = false
                    print(error?.localizedDescription ?? "Unknown error")
                    self.errorMessageLabel.text = error?.localizedDescription ?? "Unknown error"
                }
            }
        }else if logInSignUpButton.currentTitle == "Sign Up"{
            if password == confirmPasswordTextField.text{
                Auth.auth().createUser(withEmail: email, password: password) { (authResult: AuthDataResult?, error: Error?) in
                    let user = authResult?.user
                    
                    if user != nil{
                        
                        //Adding user to the database
                        let ref = Database.database().reference().child("users")
                        let userObject = [
                            "username": self.emailTextField.text!,
                            "timestamp": [".sv": "timestamp"],
                            "good": 0,
                            "bad": 0 ] as [String: Any]
                        ref.child((user?.uid)!).setValue(userObject)
                        //End database entry
                        
                        self.performSegue(withIdentifier: "logInSegue", sender: self)
                    }else{
                        self.errorMessageLabel.isHidden = false
                        self.errorMessageLabel.text = error?.localizedDescription ?? "Unknown error"
                        print(error?.localizedDescription ?? "Unknown error")
                    }
                }
            }else{ // password do not match
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = "Passwords do not match."
                print("Passwords do not match")
            }
        }
    }
    
    
}
