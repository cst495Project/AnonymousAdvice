//
//  PostViewController.swift
//  AnonAdvice
//
//  Created by John Doe on 10/18/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var postTitle: String?
    var postText: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = postTitle
        textLabel.text = postText
    }

}
