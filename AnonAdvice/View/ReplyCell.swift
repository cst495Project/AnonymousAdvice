//
//  ReplyCell.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/27/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

protocol cellDelegate {
    func cellDelegate()
}

class ReplyCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var goodPoints: UILabel!
    @IBOutlet weak var badPoints: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var replyTextLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    var delegate: cellDelegate?
    var goodTapGesture: UITapGestureRecognizer!
    var badTapGesture: UITapGestureRecognizer!
    var postId: String!
    var replyId: String!
    var reply: Reply!
    var charCountLabel: UILabel!
    var commentCount: Int!
    let current = Auth.auth().currentUser!.uid
    var currentRating: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        charCountLabel = UILabel(frame: CGRect(x:0, y:0, width:10, height: 10))
        goodTapGesture = UITapGestureRecognizer(target: self, action: #selector(ReplyCell.tapEdit(sender:)))
        badTapGesture = UITapGestureRecognizer(target: self, action: #selector(ReplyCell.tapEdit(sender:)))
        self.goodPoints.addGestureRecognizer(goodTapGesture)
        self.badPoints.addGestureRecognizer(badTapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func tapEdit(sender: UITapGestureRecognizer) {
        let replyRef = Database.database().reference().child("posts").child(postId!).child("replies").child(replyId).child("rated")
        replyRef.child(self.current).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                self.currentRating = snapshot.value! as? String
                if self.currentRating == "good" && sender == self.badTapGesture {
                    self.rate(type: "bad")
                    self.increaseScore(type: "bad")
                    self.decreaseScore(type: self.currentRating)
                } else if self.currentRating == "bad" && sender == self.goodTapGesture {
                    self.rate(type: "good")
                    self.increaseScore(type: "good")
                    self.decreaseScore(type: self.currentRating)
                }
            } else {
                if sender == self.goodTapGesture {
                    self.rate(type: "good")
                    self.increaseScore(type: "good")
                } else {
                    self.rate(type: "bad")
                    self.increaseScore(type: "bad")
                }
            }
        })
    }
    
    func rate(type: String) {
        let replyRef = Database.database().reference().child("posts").child(postId!).child("replies").child(replyId).child("rated").child(current)
        replyRef.setValue(type, withCompletionBlock: { error, ref in
            if error == nil {
                self.delegate?.cellDelegate()
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
    func increaseScore(type: String!) {
        let userRef = Database.database().reference().child("users").child(self.reply.author).child("score").child(type)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let score = snapshot.value as? Int
                userRef.setValue(score! + 1)
            } else {
                userRef.setValue(1)
            }
        })
    }
    
    func decreaseScore(type: String!) {
        let userRef = Database.database().reference().child("users").child(self.reply.author).child("score").child(type)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let score = snapshot.value! as? Int
                if score! > 0 {
                    userRef.setValue(score! - 1)
                }
            }
        })
    }
    
    @IBAction func onReply(_ sender: Any) {
        createCommentAlert(reply: reply)
    }
    
    func createCommentAlert(reply: Reply) {
        let width = UIScreen.main.bounds.width
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: CGFloat(width * 0.9),
            kTitleFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: true,
            showCircularIcon: false
        )
        let alert = SCLAlertView(appearance: appearance)
        charCountLabel.text = "140"
        charCountLabel.sizeToFit()
        charCountLabel.textColor = UIColor.gray
        alert.customSubview = charCountLabel
        let txt = alert.addTextView()
        txt.delegate = self
        alert.addButton("Comment") {
            let comment = txt.text ?? ""
            if comment != "" {
                self.commentOnReply(comment: comment)
            } else {
                SCLAlertView().showError("Comment Creation Error", subTitle: "Comments cannot be empty!")
            }
        }
        alert.showInfo(reply.text, subTitle: "")
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let charLimit = 140
        let newText = NSString(string: textView.text!).replacingCharacters(in: range, with: text)
        charCountLabel.text = String(charLimit - newText.count)
        return newText.count < charLimit
    }
    
    func commentOnReply(comment: String) {
        AnonFB.createComment(comment, postId: postId, replyId: replyId) { (Error) in
            self.commentCount = self.commentCount + 1
            self.commentsLabel.text = "comments: \(String(self.commentCount))"
            self.delegate?.cellDelegate()
        }
    }
    
}
