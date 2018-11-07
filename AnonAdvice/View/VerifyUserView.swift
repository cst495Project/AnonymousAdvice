//
//  VerifyUserView.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 11/7/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class VerifyUserView: UIView {
    
    let currentUser = Auth.auth().currentUser
    let userRef = Database.database().reference().child("users")

    let emailTextField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = .white
        t.autocapitalizationType = .none
        t.isUserInteractionEnabled = false
        t.keyboardType = .emailAddress
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.logInPopUp()
        self.emailTextField.text = currentUser?.email
        self.emailTextField.isUserInteractionEnabled = false

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func logInPopUp(){
        addSubview(verifyLabel)
        verifyLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        verifyLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        verifyLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        verifyLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(emailTextField)
        emailTextField.topAnchor.constraint(greaterThanOrEqualTo: verifyLabel.bottomAnchor, constant: 20).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(errorMessageLabel)
        errorMessageLabel.topAnchor.constraint(equalTo: verifyLabel.bottomAnchor).isActive = true
        errorMessageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        errorMessageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        errorMessageLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor).isActive = true
        
        addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(verifyButton)
        verifyButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20).isActive = true
        verifyButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        verifyButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        verifyButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
