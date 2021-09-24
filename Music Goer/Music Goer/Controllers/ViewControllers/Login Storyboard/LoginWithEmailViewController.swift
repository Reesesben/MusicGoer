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
        colorGradient()
        emailTextField.layer.cornerRadius = emailTextField.frame.height / 2
        passwordTextField.layer.cornerRadius = passwordTextField.frame.height / 2
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.backgroundColor = UIColor(cgColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
        loginButton.colorGradient(colors: [CGColor.init(red: 0.5, green: 0, blue: 0.5, alpha: 1), CGColor.init(red: 0.125, green: 0.125, blue: 0.75, alpha: 1), CGColor.init(red: 0, green: 0.5, blue: 0.5, alpha: 1)])
  
    }
    
    //MARK: - Helper Func
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.red.cgColor, UIColor.systemOrange.cgColor, UIColor.yellow.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
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
                
                CredentialsController.shared.currentCredentials = Credentials(email: email, password: password, type: CredentialsConstants.emailTypeKey)
                CredentialsController.shared.saveToPresistenceStore()
                
                guard let currentUser = Auth.auth().currentUser else { return }
                MUserController.shared.fetchUser(googleRef: currentUser.uid) { didFind in
                    if didFind {
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(identifier: "MainTabBarController")
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Login", bundle: nil)
                            let vc = storyboard.instantiateViewController(identifier: "requiredSetUp")
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}//End Of Class

extension UIButton {
    func colorGradient(colors: [CGColor]) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.height/2

        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayer.shadowRadius = 5.0
        gradientLayer.shadowOpacity = 0.3
        gradientLayer.masksToBounds = false

        self.layer.insertSublayer(gradientLayer, at: 0)
        self.contentVerticalAlignment = .center
        self.setTitleColor(UIColor.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.titleLabel?.textColor = UIColor.white
    }
}//End of extension
