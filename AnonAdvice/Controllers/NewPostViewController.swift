//
//  ComposeViewController.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    let current = Auth.auth().currentUser!.uid
    var currentUserCity: String!

    var postId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersCity()
        
        
    }
    
    func getUsersCity(){
        Database.database().reference().child("users").child(current).child("city").observeSingleEvent(of: .value) { (snapshot) in
            self.currentUserCity = snapshot.value as? String
        }
    }
    
    @IBAction func onTapAskAdvice(_ sender: Any) {
        if titleLabel.text != "" && textView.text != "" {
            let postRef = Database.database().reference().child("posts").childByAutoId()
            let postObject = [
                "author": current,
                "title": titleLabel.text!,
                "text": textView.text!,
                "timestamp": [".sv": "timestamp"],
                "city" : currentUserCity!
                ] as [String: Any]
            
            postRef.setValue(postObject, withCompletionBlock: { error, ref in
                if error == nil {
                    self.postId = postRef.key
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
