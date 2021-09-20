//
//  FirstLoginViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/20/21.
//

import UIKit

class FirstLoginViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var LoginButton: UIButton!
    @IBOutlet var SignUpButton: UIButton!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginButton.layer.cornerRadius = LoginButton.frame.height / 2
        SignUpButton.layer.cornerRadius = SignUpButton.frame.height / 2
    }
}
