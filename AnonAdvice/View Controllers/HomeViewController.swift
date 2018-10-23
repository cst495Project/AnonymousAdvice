//
//  HomeViewController.swift
//  AnonAdvice
//
//  Created by Raeleen Watson on 10/22/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

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
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
