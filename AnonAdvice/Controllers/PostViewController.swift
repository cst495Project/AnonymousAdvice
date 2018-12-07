//
//  PostViewController.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/18/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
import DateToolsSwift
import AlamofireImage
import NightNight
import SCLAlertView

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, cellDelegate {
    
    //TODO:
    //      add a tap author's text to expand? (maybe with a view animation)
    //      resize cell upon selection

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet var thisView: UIView!
    var postId: String?
    var author: String?
    var replies: [Reply] = []
    var refreshControl = UIRefreshControl()
    var sourceView: String! = "Home"
    let currentUser = Auth.auth().currentUser?.uid
    var adviceFavorited: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: #selector(PostViewController.didPullToRefresh(_ :)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        if sourceView == "Home"{
            leftButton.setTitle("Home", for: .normal)
        } else {
            leftButton.setTitle("Profile", for: .normal)
        }
        
        activityIndicator.startAnimating()
        
        getPost()
        getPostReplies()
        
        thisView.mixedBackgroundColor = MixedColor(normal: thisView.backgroundColor ?? .white, night: .black)
        tableView.mixedBackgroundColor = MixedColor(normal: tableView.backgroundColor ?? .white, night: .black)
        titleLabel.mixedTextColor = MixedColor(normal: titleLabel.textColor, night: .white)
        textLabel.mixedTextColor = MixedColor(normal: textLabel.textColor, night: .white)
    }
    
    @IBAction func onHome(_ sender: Any) {
        if sourceView == "Home" {
            self.performSegue(withIdentifier: "unwindToHome", sender: self)
        } else {
            self.performSegue(withIdentifier: "unwindToProfile", sender: self)
        }
    }
    
    @IBAction func onRightButton(_ sender: UIButton) {
        performSegue(withIdentifier: "createReply", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "createReply") {
            let rvc = segue.destination as! ReplyViewController
            rvc.postID = postId
            rvc.parentTitle = titleLabel.text
            rvc.parentText = textLabel.text
        }
    }
    
    @IBAction func onExpand(_ sender: Any) {
        let width = UIScreen.main.bounds.width
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: CGFloat(width * 0.9),
            kTextViewdHeight: 300,
            kTitleFont: UIFont(name: "HelveticaNeue-Bold", size: 17)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 17)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: true,
            showCircularIcon: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextView()
        txt.isEditable = false
        txt.text = textLabel.text
        alert.showInfo(titleLabel.text!, subTitle: "")
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        activityIndicator.startAnimating()
        getPostReplies()
    }
    
    func cellDelegate() {
        getPost()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyCell
        cell.selectionStyle = .none
        cell.replyTextLabel.text = replies[indexPath.row].text
        cell.replyTextLabel.mixedTextColor = MixedColor(normal: cell.replyTextLabel.textColor ?? .black, night: .white)
        cell.timestampLabel.text = "\(String(describing: replies[indexPath.row].timestamp))"
        cell.goodPoints.text = "Good: \(abbreviate(num: replies[indexPath.row].good))"
        cell.badPoints.text = "Bad: \(abbreviate(num: replies[indexPath.row].bad))"
        cell.reply = replies[indexPath.row]
        cell.replyId = replies[indexPath.row].id
        cell.postId = postId
        
        if author != currentUser{
            cell.bestAdviceButton.isHidden = true
        }
        cell.mixedBackgroundColor = MixedColor(normal: cell.backgroundColor ?? .white, night: .black)
        if replies[indexPath.row].author == currentUser {
            cell.mixedBackgroundColor = MixedColor(normal: 0xe0e0e0, night: 0x303030)
        }
        
        if cell.replyId == self.adviceFavorited {
            cell.bestAdviceButton.isEnabled = true
            cell.bestAdviceButton.setImage(ImageAssets.selectedHeart, for: .normal)
        }else if self.adviceFavorited != "n/a" && cell.replyId != self.adviceFavorited{
            cell.bestAdviceButton.setImage(ImageAssets.unselectedHeart, for: .normal)
            cell.bestAdviceButton.isEnabled = false
        }else if self.adviceFavorited == "n/a"{
            cell.bestAdviceButton.isEnabled = true
            cell.bestAdviceButton.setImage(ImageAssets.unselectedHeart, for: .normal)
        }
        let urlBaseString = "https://api.adorable.io/avatars/75/"
        let urlMiddleString1 = replies[indexPath.row].author
        var urlMiddleString2 = postId!
        urlMiddleString2.remove(at: urlMiddleString2.startIndex)
        let urlEndString = ".png"
        let url = URL(string: urlBaseString + urlMiddleString1 + urlMiddleString2 + urlEndString)
        cell.avatarImage.af_setImage(withURL: url!)
        
        let commentSnap = replies[indexPath.row].comments
        let comments = AnonFB.getComments(commentSnap: commentSnap!)
        let commentLabel = addComments(comments: comments)
        cell.commentCount = comments.count
        cell.commentsLabel.text = "comments: \(String(comments.count))"
        cell.commentLabel.text = commentLabel
        cell.commentLabel.mixedTextColor = MixedColor(normal: .black, night: .white)
        cell.delegate = self
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return replies[indexPath.row].author == currentUser
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteReply(indexPath: indexPath) {_ in 
                tableView.beginUpdates()
                self.replies.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                tableView.reloadData()
            }
        }
    }
    
    func abbreviate(num: Int) -> String {
        var n = Double(num)
        if num >= 1000 && num < 1000000 {
            n = Double( floor(n/100)/10 )
            return "\(n.description)K"
        } else if num >= 1000000 {
            n = Double( floor(n/100000)/10 )
            return "\(n.description)M"
        }
        return "\(num)"
    }
    
    // ******** DATABASE & SNAPSHOT CALLS ********
    
    func getPost() {
        AnonFB.fetchPost(postId!) { (post) in
            let urlBaseString = "https://api.adorable.io/avatars/75/\(post.author)"
            var urlMiddleString2 = self.postId!
            urlMiddleString2.remove(at: urlMiddleString2.startIndex)
            let urlEndString = ".png"
            let url = URL(string: urlBaseString + urlMiddleString2 + urlEndString)
            self.avatarImage.af_setImage(withURL: url!)
            self.titleLabel.text = post.title
            self.textLabel.text = post.text
            self.author = post.author
            self.adviceFavorited = post.favorite
        }
        getPostReplies()
    }
    
    func deleteReply(indexPath: IndexPath, completionblock: @escaping ((Error?)-> Void )) {
        let alert = SCLAlertView()
        alert.addButton("Delete") {
            let rid = self.replies[indexPath.row].id
            AnonFB.deleteReply(self.postId, replyId: rid, completionblock: { (Error) in
                if Error != nil {
                    print(Error?.localizedDescription as Any)
                } else {
                    completionblock(Error)
                }
            })
        }
        alert.showWarning("Confirmation Needed", subTitle: "Are you sure you want to delete your reply?")
    }
    
    func getPostReplies() {
        AnonFB.fetchReplies(postId!) { (Replies) in
            self.replies = Replies.sorted(by: {$0.good > $1.good})
            self.tableView.reloadData()
        }
        Database.database().reference().child("posts").child(postId!).child("favorite").observeSingleEvent(of: .value) { (DataSnapshot) in
            self.adviceFavorited = DataSnapshot.value as? String
            self.tableView.reloadData()
        }
        self.refreshControl.endRefreshing()
        self.activityIndicator.stopAnimating()
    }
    
    func addComments(comments: [Comment]) -> String {
        var newString: String = ""
        for comment in comments {
            newString = newString + "-------------------\n\(comment.text)\n"
        }
        return newString
    }
    
}
