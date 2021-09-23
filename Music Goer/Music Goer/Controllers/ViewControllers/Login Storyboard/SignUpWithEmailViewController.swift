//
//  SignUpWithEmailViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/21/21.
//

import UIKit
import FirebaseAuth

class SignUpWithEmailViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet var passwordInformationButton: UIButton!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordInformationButton.setTitle("", for: .normal)
        signupButton.layer.cornerRadius = signupButton.frame.height / 2
    }
    
    //MARK: - Actions
    @IBAction func passwordInfoPressed(_ sender: Any) {
        displayError(title: "Password Format", Body: "Password must be 8 characters long and contain 1 symbol")
    }
    @IBAction func signUpButtonTapped(_ sender: Any) {
        if signupButton.title(for: .normal) == "Sign Up" {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let password2 = confirmPasswordTextField.text else { return }
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        
        if email.isEmpty {
            emailTextField.placeholder = "Email cannot be empty"
            displayError(title: "Email cannot be empty!", Body: "The email text field cannot be empty.")
        } else if password.isEmpty {
            passwordTextField.placeholder = "Password cannot be empty"
            displayError(title: "Your password doesn't meet the requirements", Body: "Your password must be 8 Charecters or longer and contain 1 symbol")
        } else if password2 != password {
            confirmPasswordTextField.placeholder = "Confirm Password cannot be empty"
            displayError(title: "Your passwords don't match!", Body: "Your passwords don't match! Try typing them in again.")
        } else if !email.contains("@") {
            displayError(title: "Your email adress is invalid", Body: "Your email address doesn't match email format.")
        } else if !passwordTest.evaluate(with: password) {
            displayError(title: "Your password isn't formatted correctly", Body: "Your password must be 8 Charecters or longer and contain 1 symbol")
        } else if email.contains("@") && !email.isEmpty && !password.isEmpty && password == password2 {
            Auth.auth().createUser(withEmail: email, password: password) { Result, error in
                if let error = error {
                    print("Not Yeet")
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    if error.localizedDescription == "The email address is already in use by another account." {
                        self.displayError(title: "Email already being used by another account", Body: "This email is already being used by another account!")
                    }
                    return
                }
                CredentialsController.shared.currentCredentials = Credentials(email: email, password: password, type: CredentialsConstants.emailTypeKey)
                CredentialsController.shared.saveToPresistenceStore()
                print("Successfully created user")
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "requiredSetUp")
                self.navigationController?.pushViewController(vc, animated: true)
                self.signupButton.setTitle("Next", for: .normal)
            }
        }
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "requiredSetUp")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
