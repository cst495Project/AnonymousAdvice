//
//  NewPostViewController.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import NightNight

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var thisView: UIView!
    
    let current = Auth.auth().currentUser!.uid
    var currentUserCity: String!
    var postId: String!
    
    let subjectSelector = SubjectSelector()
    let replyButton = UIBarButtonItem(title: "Ask", style: .plain, target: self, action: #selector(onTapAskAdvice))

    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersCity()
        setUpView()
        self.navigationItem.rightBarButtonItem = replyButton
        thisView.mixedBackgroundColor = MixedColor(normal: thisView.backgroundColor ?? .white, night: .black)
        titleLabel.mixedTextColor = MixedColor(normal: titleLabel.textColor ?? .black, night: .white)
        textView.mixedTextColor = MixedColor(normal: textView.textColor ?? .black, night: .white)
        let borderColor: UIColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = borderColor.cgColor
        textView.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        titleLabel.becomeFirstResponder()
    }
    
    fileprivate func setUpView(){
        view.addSubview(subjectSelector)
        subjectSelector.translatesAutoresizingMaskIntoConstraints = false
        subjectSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        subjectSelector.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        subjectSelector.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        subjectSelector.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func getUsersCity(){
        Database.database().reference().child("users").child(current).child("city").observeSingleEvent(of: .value) { (snapshot) in
            self.currentUserCity = snapshot.value as? String
        }
    }
    
    @objc func onTapAskAdvice() {
        if titleLabel.text != "" && textView.text != "" {
            let postRef = Database.database().reference().child("posts").childByAutoId()
            let postObject = [
                "author": current,
                "title": titleLabel.text!,
                "text": textView.text!,
                "timestamp": [".sv": "timestamp"],
                "city" : currentUserCity!,
                "subject" : subjectSelector.currentSelectedSubject(),
                "favorite" : "n/a",
                "count": 0
                ] as [String: Any]
            postRef.setValue(postObject, withCompletionBlock: { error, ref in
                if error == nil {
                    self.postId = postRef.key
                    let user = Database.database().reference().child("users").child(self.current).child("posts")
                    user.child(postRef.key!).setValue(self.titleLabel.text!)
                    self.performSegue(withIdentifier: "createPost", sender: self)
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        } else {
            SCLAlertView().showError("Post Creation Failed", subTitle: "One or more empty fields!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! UINavigationController
        let pvc = dest.topViewController as! PostViewController
        pvc.postId = postId
    }
    
}
