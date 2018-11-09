//
//  UserPostCell.swift
//  AnonAdvice
//
//  Created by Devin Hight on 11/9/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

class UserPostCell: UITableViewCell {
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
