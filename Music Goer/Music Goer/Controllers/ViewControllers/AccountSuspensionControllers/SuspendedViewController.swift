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
    @IBOutlet weak var warningImage: UIImageView!
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let current = MUserController.shared.currentUser,
              let lastReport = current.lastReport else { return }
        let currentDate = Date()
        colorGradient()
        messageLabel.backgroundColor = .black
        messageLabel.alpha = 0.75
        messageLabel.textColor = .white
        guard let timeInterval = Calendar.current.dateComponents([.day], from: lastReport, to: currentDate).day else { return }
        let daysLeft = 30 - timeInterval
        
        messageLabel.text = "Due to community reports your account has been suspended. It will be reactivated in \(String(describing: daysLeft)) days."
    }

    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.black.cgColor, UIColor.red.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
