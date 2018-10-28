//
//  CityPickerViewController.swift
//  AnonAdvice
//
//  Created by Jesus Andres Bernal Lopez on 10/27/18.
//  Copyright © 2018 AnonAdvice. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class CityPickerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let placePicker = GMSAutocompleteViewController()
//        placePicker.delegate = self as? GMSAutocompleteViewControllerDelegate
//        present(placePicker, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
}
    
    // The code snippet below shows how to create and display a GMSPlacePickerViewController.
//    @IBAction func pickPlace(_ sender: UIButton) {
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePickerViewController(config: config)
//        placePicker.delegate = self
//
//        present(placePicker, animated: true, completion: nil)
        
//        let placePicker = GMSAutocompleteViewController()
//        placePicker.delegate = self as? GMSAutocompleteViewControllerDelegate
//        present(placePicker, animated: true, completion: nil)
//    }

    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
//    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
//        print("hello")
//        // Dismiss the place picker, as it cannot dismiss itself.
////        viewController.dismiss(animated: true, completion: nil)
//
//        print("Place name \(place.name)")
//        print("Place address \(String(describing: place.formattedAddress))")
//        print("Place attributions \(String(describing: place.attributions))")
//    }
//
//    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
//        // Dismiss the place picker, as it cannot dismiss itself.
////        viewController.dismiss(animated: true, completion: nil)
//
//        print("No place selected")
//    }
    
    
    
    
    
    
    
//    @IBAction func citySelected(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//}

//extension CityPickerViewController: GMSAutocompleteViewControllerDelegate {
//
//    // Handle the user's selection.
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
////        place.
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        // TODO: handle the error.
//        print("Error: ", error.localizedDescription)
//    }
//
//    // User canceled the operation.
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//
//}
