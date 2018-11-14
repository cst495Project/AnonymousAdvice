//
//  ComposeViewController.swift
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
    let askAdviceButton = UIBarButtonItem(title: "Ask", style: .plain, target: self, action: #selector(onTapAskAdvice))

    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersCity()
        setUpView()
        self.navigationItem.rightBarButtonItem = askAdviceButton
        thisView.mixedBackgroundColor = MixedColor(normal: 0xf0f0f0, night: 0x800f0f)
        
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
                "subject" : subjectSelector.currentSelectedSubject()
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
