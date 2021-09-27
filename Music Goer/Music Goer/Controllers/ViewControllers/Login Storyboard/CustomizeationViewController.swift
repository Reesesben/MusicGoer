//
//  CustomizeationViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/21/21.
//

import UIKit
import FirebaseAuth

class CustomizeationViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var finishButton: UIButton!
    @IBOutlet var usernameTextField: UITextField!
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        colorGradient()
        finishButton.layer.cornerRadius = finishButton.frame.height / 2
        
    }
    //MARK: - Properties
    var userImage: UIImage?
    
    //MARK: - Helper Func
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: - Actions
    @IBAction func finishButtonTapped(_ sender: Any) {
        
        if userImage == nil {
            displayError(title: "You need to select an image", Body: "You need to select an image so other poeple can find you on the app.")
        } else if (usernameTextField.text == "") {
            displayError(title: "You need to provide a username", Body: "You need to provide a username so users can identify you in the app")
        } else {
            
            guard let userImage = userImage,
                  let username = usernameTextField.text, !username.isEmpty,
                  let user = Auth.auth().currentUser,
                  let imageData = userImage.jpegData(compressionQuality: 0.5) else { return }
            
            MUserController.shared.createUser(userName: username, userImage: imageData, googleRef: user.uid) {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerSegue" {
            guard let destination = segue.destination as? PhotoPickerViewController else { return }
            destination.delegate = self
        }
    }
}

extension CustomizeationViewController: photoPickerDelegate {
    func didSelectNewImage(image: UIImage) {
        self.userImage = image
    }
}
