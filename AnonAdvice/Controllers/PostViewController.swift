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
    
    @IBOutlet var thisView: UIView!
    var postId: String?
    var replies: [Reply] = []
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: #selector(PostViewController.didPullToRefresh(_ :)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        activityIndicator.startAnimating()
        
        getPost()
        getPostReplies()
        
        thisView.mixedBackgroundColor = MixedColor(normal: 0xf0f0f0, night: 0x800f0f)
        
    }
    
    @IBAction func onHome(_ sender: Any) {
        performSegue(withIdentifier: "home", sender: nil)
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
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl)
    {
        activityIndicator.startAnimating()
        getPostReplies()
    }
    
    func cellDelegate() {
        getPostReplies()
        tableView.reloadData()
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
        cell.replyTextLabel.text = replies[indexPath.row].text
        cell.timestampLabel.text = "\(String(describing: replies[indexPath.row].timestamp))"
        cell.goodPoints.text = "\(String(replies[indexPath.row].good))"
        cell.badPoints.text = "\(String(replies[indexPath.row].bad))"
        cell.reply = replies[indexPath.row]
        cell.replyId = replies[indexPath.row].id
        cell.postId = postId
        
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
        cell.delegate = self
        return cell
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
        }
    }
    
    func getPostReplies() {
        AnonFB.fetchReplies(postId!) { (Replies) in
            self.replies = Replies.sorted(by: {$0.good > $1.good})
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
