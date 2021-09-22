//
//  LoginWithEmailViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/21/21.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class LoginWithEmailViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.cornerRadius = emailTextField.frame.height / 2
        passwordTextField.layer.cornerRadius = passwordTextField.frame.height / 2
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
    }
    
    //MARK: - Actions
    @IBAction func LoginWasTapped(_ sender: Any) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else { return }
        
        if email.isEmpty {
            displayError(title: "Email Cannot be blank!", Body: "You need to provide an email that your account is linked to.")
        }
        
        if password.isEmpty {
            displayError(title: "Password Cannot be blank", Body: "You need to provide a password for your account!")
        }
        
        if !email.isEmpty && !password.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    self.displayError(title: "Could not find account!", Body: "There was an error retrieving your account. Ensure you have the correct username and password")
                }
                
                guard let currentUser = Auth.auth().currentUser else { return }
                MUserController.shared.fetchUser(googleRef: currentUser.uid) { _ in
                    print("Sucessfully logged in!")
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
            
        }
        
    }
    
    //MARK: - Helper Methods
    func displayError(title: String, Body: String) {
        let Alert = UIAlertController(title: title, message: Body, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default) { _ in
            self.emailTextField.text = ""
        }
        Alert.addAction(okay)
        self.present(Alert, animated: true, completion: nil)
    }
    
}
