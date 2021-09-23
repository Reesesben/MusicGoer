//
//  ErrorPresent.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/22/21.
//

import Foundation
import UIKit

extension UIViewController {
    /**
        Presents an alert on the presenting view
     
     - Parameter title: The title text for the alert
     - Parameter Body: The body text for the alert
     */
    func displayError(title: String, Body: String) {
        let Alert = UIAlertController(title: title, message: Body, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default)
        Alert.addAction(okay)
        self.present(Alert, animated: true, completion: nil)
    }
}
