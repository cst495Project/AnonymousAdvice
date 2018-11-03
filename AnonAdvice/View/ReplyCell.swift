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

class ReplyCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var goodPoints: UILabel!
    @IBOutlet weak var badPoints: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var replyTextLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var goodTapGesture: UITapGestureRecognizer!
    var badTapGesture: UITapGestureRecognizer!
    var postId: String!
    var replyId: String!
    var reply: Reply!
    var charCountLabel: UILabel!
    var commentSnap: DataSnapshot!
    var comments: [Comment] = []
    var commentCount: Int!
    var hide: Bool!

    override func awakeFromNib() {
        super.awakeFromNib()
        charCountLabel = UILabel(frame: CGRect(x:0,y:0,width:10, height: 10))
        goodTapGesture = UITapGestureRecognizer(target: self, action: #selector(ReplyCell.tapEdit(sender:)))
        badTapGesture = UITapGestureRecognizer(target: self, action: #selector(ReplyCell.tapEdit(sender:)))
        self.goodPoints.addGestureRecognizer(goodTapGesture)
        self.badPoints.addGestureRecognizer(badTapGesture)
        //self.commentLabel.isHidden = true
        //self.hide = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.commentLabel.isHidden = hide
        //self.hide = !self.hide
    }
    
    @objc func tapEdit(sender: UITapGestureRecognizer) {
        if sender == goodTapGesture {
            //TODO: stop user from liking more than once
            let goodCount = reply.good + 1
            goodPoints.text = String(goodCount)
            let goodRef = Database.database().reference().child("posts").child(postId!).child("replies").child(replyId).child("good")
            goodRef.setValue(goodCount, withCompletionBlock: { error, ref in
                if error == nil {
                    print("Good Points Saved")
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        } else {
            //TODO: stop user from disliking more than once
            let badCount = reply.good + 1
            badPoints.text = String(badCount)
            let badRef = Database.database().reference().child("posts").child(postId!).child("replies").child(replyId).child("bad")
            badRef.setValue(badCount, withCompletionBlock: { error, ref in
                if error == nil {
                    print("Bad Points Saved")
                } else {
                    print(error?.localizedDescription as Any)
                }
            })
        }
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
            print("Text value: \(txt.text ?? "")")
            let comment = txt.text ?? ""
            self.commentOnReply(comment: comment)
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
        let current = Auth.auth().currentUser!.uid
        let replyRef = Database.database().reference().child("posts").child(postId!).child("replies").child(replyId).child("comments").childByAutoId()
        let commentObject = [
            "author": current,
            "text": comment,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]
        replyRef.setValue(commentObject, withCompletionBlock: { error, ref in
            if error == nil {
                print("Success!")
                self.commentCount = self.commentCount + 1
                self.commentsLabel.text = String(self.commentCount)
            } else {
                print(error?.localizedDescription as Any)
            }
        })
    }
    
}
