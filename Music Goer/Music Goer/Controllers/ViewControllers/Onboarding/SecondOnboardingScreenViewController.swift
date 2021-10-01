//
//  SecondOnboardingScreenViewController.swift
//  Music Goer
//
//  Created by Delstun McCray on 10/1/21.
//

import UIKit

class SecondOnboardingScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorGradient()

        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        upSwipe.direction = .up
        downSwipe.direction = .down

        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)

    }

    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .up
        {
           print("Swipe up")
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "thirdScreenID")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }

        if sender.direction == .down
        {
            self.dismiss(animated: true, completion: nil)
        }
    }//End of func
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor, UIColor.black.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }//End of func
}//End of class
