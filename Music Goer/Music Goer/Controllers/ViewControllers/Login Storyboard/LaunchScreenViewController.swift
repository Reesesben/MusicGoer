//
//  LaunchScreenViewController.swift
//  Music Goer
//
//  Created by Delstun McCray on 9/28/21.
//

import UIKit
import FirebaseAuth

class LaunchScreenViewController: UIViewController {

        private let imageView = UIImageView(image: #imageLiteral(resourceName: "MusicGoersLogo"))
        

        override func viewDidLoad() {
            super.viewDidLoad()
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            colorGradient()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            // get rid of the default constraints
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // "drag out" new constraints
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            self.animate()
        }
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
        
        private func animate() {
            // spend 1 second animating
            UIView.animate(withDuration: 1, animations: {
                
                // grow the imageview
                self.imageView.transform = CGAffineTransform(scaleX: 3, y: 3)
                
                // hide the imageview
                self.imageView.alpha = 0
                
            }, completion: { _ in
                
                // same as SceneDelegate, replace initial view controller with a new one
                UIApplication.shared.windows.first?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            })
        }//end of func
    }
