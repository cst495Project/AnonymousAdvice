//
//  CityPickerViewController.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 10/27/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit

class CityPickerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func citySelected(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
