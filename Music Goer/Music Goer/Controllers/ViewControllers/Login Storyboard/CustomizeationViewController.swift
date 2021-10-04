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
    @IBOutlet var loadingWheel: UIActivityIndicatorView!
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        loadingWheel.isHidden = true
        colorGradient()
        finishButton.layer.cornerRadius = finishButton.frame.height / 2
        self.hideKeyboardWhenTappedAround()
        
    }
    //MARK: - Properties
    var userImage: UIImage?
    var isLoading: Bool = false {
        didSet {
            loadingWheel.isHidden = !isLoading
            isLoading ? loadingWheel.startAnimating() : loadingWheel.stopAnimating()
            finishButton.isEnabled = !isLoading
        }
    }
    
    //MARK: - Helper Func
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: - Actions
    @IBAction func finishButtonTapped(_ sender: Any) {
        isLoading = true
        if userImage == nil {
            displayError(title: "You need to select an image", Body: "You need to select an image so other poeple can find you on the app.")
            isLoading = false
        } else if (usernameTextField.text == "") {
            displayError(title: "You need to provide a username", Body: "You need to provide a username so users can identify you in the app")
            isLoading = false
        } else {
            guard let userImage = userImage,
                  let username = usernameTextField.text, !username.isEmpty,
                  let user = Auth.auth().currentUser,
                  let imageData = userImage.jpegData(compressionQuality: 0.5) else {
                      isLoading = false
                      return
                  }
            
            MUserController.shared.createUser(userName: username, userImage: imageData, googleRef: user.uid) { sucess in
                if sucess {
                    self.isLoading = false
                self.displayError(title: "Community Guidlines", Body: "If 30 or more users report your account for spam or inapropriate conduct or harasment your account will be blocked for 30 days.") { _ in
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                } else {
                    self.isLoading = false
                    self.displayError(title: "An Error occurred", Body: "An error occurred creating your account, please ensure you are connected to internet.", completion: nil)
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
