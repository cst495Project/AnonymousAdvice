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
import NightNight

class ReplyViewController: UIViewController {

    @IBOutlet weak var parentTitleLabel: UILabel!
    @IBOutlet weak var parentTextLabel: UILabel!
    @IBOutlet weak var replyTextView: UITextView!
    @IBOutlet var thisView: UIView!
    
    var postID: String?
    var parentTitle: String?
    var parentText: String?
    
    let askAdviceButton = UIBarButtonItem(title: "Reply", style: .plain, target: self, action: #selector(onPostReply(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentTitleLabel.text = parentTitle ?? ""
        parentTextLabel.text = parentText ?? ""
        thisView.mixedBackgroundColor = MixedColor(normal: 0xf0f0f0, night: 0x800f0f)
        let borderColor: UIColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0)
        replyTextView.layer.borderWidth = 1
        replyTextView.layer.borderColor = borderColor.cgColor
        replyTextView.layer.cornerRadius = 5.0
        self.navigationItem.rightBarButtonItem = askAdviceButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        replyTextView.becomeFirstResponder()
    }

    @objc func onPostReply(_ sender: Any) {
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
                    let user = Database.database().reference().child("users").child(current).child("replies")
                    user.child(replyRef.key!).setValue(self.postID!)
                    let _ = self.navigationController?.popViewController(animated: true)
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        } else {
            SCLAlertView().showError("Reply Creation Failed", subTitle: "Replies cannot be empty!")
        }
    }
    
}
