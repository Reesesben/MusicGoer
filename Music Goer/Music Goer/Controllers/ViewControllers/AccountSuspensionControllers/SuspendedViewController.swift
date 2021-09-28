//
//  SuspendedViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/28/21.
//

import UIKit

class SuspendedViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var messageLabel: UILabel!
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let current = MUserController.shared.currentUser,
              let lastReport = current.lastReport else { return }
        let currentDate = Date()
        
        guard let timeInterval = Calendar.current.dateComponents([.day], from: lastReport, to: currentDate).day else { return }
        let daysLeft = 30 - timeInterval
        
        messageLabel.text = "Due to community reports your account has been suspended. It will be reactivated in \(String(describing: daysLeft)) days."
    }
}
