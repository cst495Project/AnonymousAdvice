//
//  ComposeViewController.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/17/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    var postId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onTapAskAdvice(_ sender: Any) {
        let current = Auth.auth().currentUser!.uid
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let postObject = [
            "author": current,
            "title": titleLabel.text!,
            "text": textView.text!,
            "timestamp": [".sv": "timestamp"]
                ] as [String: Any]
        
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                self.postId = postRef.key
                self.performSegue(withIdentifier: "createPost", sender: self)
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! UINavigationController
        let pvc = dest.topViewController as! PostViewController
        pvc.postId = postId
    }
    
}
