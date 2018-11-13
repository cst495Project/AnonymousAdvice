//
//  LogInViewController.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GooglePlacePicker
import FirebaseDatabase
import FirebaseAuth

class LogInViewController: UIViewController, GMSAutocompleteViewControllerDelegate {

    @IBOutlet weak var logInSignUpSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var logInSignUpButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet var tableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground()
        logIn()
        logInSignUpSegmentedControl.addTarget(self, action: #selector(layout), for: .valueChanged)
        confirmPasswordTextField.isSecureTextEntry = true
        passwordTextField.isSecureTextEntry = true
        errorMessageLabel.isHidden = true
    }
    
    func setBackground(){
        logInSignUpButton.backgroundColor = .white
        logInSignUpButton.layer.cornerRadius = 5
        logInSignUpButton.layer.borderWidth = 1
        logInSignUpButton.layer.borderColor = UIColor.white.cgColor
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let gradient = CAGradientLayer()
        
        gradient.frame = view.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.blue.cgColor, UIColor.green]
        gradient.startPoint = CGPoint.zero
        gradient.endPoint = CGPoint(x:1, y:1)
        
        tableView.layer.insertSublayer(gradient, at: 0)
    }
    
    @objc func layout(){
        switch logInSignUpSegmentedControl.selectedSegmentIndex {
        case 0:
            logIn()
        case 1:
            signUp()
        default:
            break
        }
    }
    
    func logIn(){
        confirmPasswordTextField.isHidden = true
        cityTextField.isHidden = true
        cityButton.isHidden = true
        logInSignUpButton.setTitle("Log In", for: .normal)
    }
    
    func signUp(){
        confirmPasswordTextField.isHidden = false
        cityTextField.isHidden = false
        cityButton.isHidden = false
        logInSignUpButton.setTitle("Sign Up", for: .normal)
    }
    
    @IBAction func onLogInSignUp(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        if logInSignUpButton.currentTitle == "Log In"{
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if user != nil{
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }else{
                    self.errorMessageLabel.isHidden = false
                    print(error?.localizedDescription ?? "Unknown error")
                    self.errorMessageLabel.text = error?.localizedDescription ?? "Unknown error"
                }
            }
        }else if logInSignUpButton.currentTitle == "Sign Up"{
            if password == confirmPasswordTextField.text && cityTextField.text != ""{
                AnonFB.signUpUser(email, password: password, city: cityTextField.text!) { (Error) in
                    if Error == nil {
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    } else {
                        self.errorMessageLabel.isHidden = false
                        self.errorMessageLabel.text = Error?.localizedDescription ?? "Unknown error"
                        print(Error?.localizedDescription ?? "Unknown error")
                    }
                    
                }
            }else if password != confirmPasswordTextField.text{ // password do not match
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = "Passwords do not match."
                print("Passwords do not match")
            }else if cityTextField.text == ""{
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = "Enter a city"
                print("Must choose a city")
            }
        }
    }
    
    @IBAction func onPickCity(_ sender: Any) {
        let placePicker = GMSAutocompleteViewController()
        placePicker.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment  //suitable filter type
        filter.type = .city
        placePicker.autocompleteFilter = filter
        
        present(placePicker, animated: true, completion: nil)

    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        cityTextField.text = place.formattedAddress!
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
