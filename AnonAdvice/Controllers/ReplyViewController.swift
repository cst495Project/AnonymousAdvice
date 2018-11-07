//
//  ReplyViewController.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/27/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class ReplyViewController: UIViewController {

    @IBOutlet weak var parentTitleLabel: UILabel!
    @IBOutlet weak var parentTextLabel: UILabel!
    @IBOutlet weak var replyTextView: UITextView!
    
    var postID: String?
    var parentTitle: String?
    var parentText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentTitleLabel.text = parentTitle ?? ""
        parentTextLabel.text = parentText ?? ""
    }

    @IBAction func onPostReply(_ sender: Any) {
        if replyTextView.text != "" {
            let current = Auth.auth().currentUser!.uid
            let postRef = Database.database().reference().child("posts").child(postID!).child("replies")
            let replyRef = postRef.childByAutoId()
            let replyObject = [
                "author": current,
                "text": replyTextView.text,
                "timestamp": [".sv": "timestamp"]
                ] as [String: Any]
            replyRef.setValue(replyObject, withCompletionBlock: { error, ref in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        } else {
            SCLAlertView().showError("Reply Creation Failed", subTitle: "Replies cannot be empty!")
        }
    }
    
}
