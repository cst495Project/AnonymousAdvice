//
//  HomeViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/22/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indexChange()
        segmentedControl.addTarget(self, action: #selector(indexChange), for: .valueChanged)
        // Do any additional setup after loading the view.
    }

    
    @IBAction func onCompose(_ sender: Any) {
        
        self.performSegue(withIdentifier: "composeSegue", sender: self)
    }
    
    
    
    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    
    
    @objc func indexChange() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            localSelected()
        case 1:
            worldSelected()
        default:
            break;
        }
    }
    
    func localSelected(){
        //functionality for local tab
    }
    
    func worldSelected() {
        //functionality for world
    }

}
