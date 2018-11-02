//
//  ReplyCell.swift
//  AnonAdvice
//
//  Created by Devin Hight on 10/27/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

class ReplyCell: UITableViewCell {

    @IBOutlet weak var goodPoints: UILabel!
    @IBOutlet weak var badPoints: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var replyTextLabel: UILabel!
    
    var goodTapGesture: UITapGestureRecognizer!
    var badTapGesture: UITapGestureRecognizer!
    var delegate: myTableDelegate?
    var reply: Reply!

    override func awakeFromNib() {
        super.awakeFromNib()
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
            delegate?.myTableDelegate(sender: "good", reply: reply)
        } else {
            delegate?.myTableDelegate(sender: "bad", reply: reply)
        }
    }
    
    @IBAction func onReply(_ sender: Any) {
        delegate?.myTableDelegate(sender: "reply", reply: reply)
    }
    
}

protocol myTableDelegate {
    func myTableDelegate(sender: String, reply: Reply)
}
