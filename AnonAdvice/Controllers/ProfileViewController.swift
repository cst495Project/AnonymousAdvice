//
//  ProfileViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/29/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    //var user = LogInViewController()
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = Auth.auth().currentUser?.email
        getCity()
        // Do any additional setup after loading the view.
    }
    
    
    func getCity() {
        let current = Auth.auth().currentUser!.uid
        let postRef = Database.database().reference().child("user").child(current)
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.cityLabel.text = value?["city"] as? String ?? ""
            
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
