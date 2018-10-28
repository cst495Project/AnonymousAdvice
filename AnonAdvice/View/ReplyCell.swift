//
//  ReplyCell.swift
//  AnonAdvice
//
//  Created by John Doe on 10/27/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

class ReplyCell: UITableViewCell {
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var replyTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
