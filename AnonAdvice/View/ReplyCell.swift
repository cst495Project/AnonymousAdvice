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
    
    var goodTapGesture: UITapGestureRecognizer!
    var badTapGesture: UITapGestureRecognizer!
    var postId: String!
    var reply: Reply!
    var charCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        charCountLabel = UILabel(frame: CGRect(x:0,y:0,width:10, height: 10))
        goodTapGesture = UITapGestureRecognizer(target: self, action: #selector(ReplyCell.tapEdit(sender:)))
        badTapGesture = UITapGestureRecognizer(target: self, action: #selector(ReplyCell.tapEdit(sender:)))
        self.goodPoints.addGestureRecognizer(goodTapGesture)
        self.badPoints.addGestureRecognizer(badTapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func tapEdit(sender: UITapGestureRecognizer) {
        if sender == goodTapGesture {
            let goodRef = Database.database().reference().child("posts").child(postId!).child("replies").child(reply.id).child("good")
                //save the point value into database
        } else {
            let badRef = Database.database().reference().child("posts").child(postId!).child("replies").child(reply.id).child("bad")
                //save the point value into database
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
        let replyRef = Database.database().reference().child("posts").child(postId!).child("replies").child(reply.id)
            //save the comment into database
    }
    
}
