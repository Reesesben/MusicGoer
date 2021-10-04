//
//  LoadingViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/28/21.
//

import UIKit
import FirebaseAuth

class LoadingViewController: UIViewController {
    //MARK: - IBoutlets
    @IBOutlet var loadingWheel: UIActivityIndicatorView!
    
    //MARK: - Properties
    var isLoading: Bool = false {
        didSet{
            DispatchQueue.main.async {
                self.loadingWheel.isHidden = !self.isLoading
                self.isLoading ? self.loadingWheel.startAnimating() : self.loadingWheel.stopAnimating()
            }
        }
    }
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        loadingWheel.isHidden = true
        isLoading = true
        CredentialsController.shared.loadFromPresistenceStore { sucess in
            if sucess {
                guard let credentials = CredentialsController.shared.currentCredentials else { return }
                if credentials.type == CredentialsConstants.emailTypeKey {
                    guard let email = credentials.email,
                          let password = credentials.password else { return }
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let error = error {
                            self.isLoading = false
                            self.showLoginScreen()
                            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        }
                        DispatchQueue.main.async {
                            self.transitionLogin()
                        }
                    }
                } else if credentials.type == CredentialsConstants.googleTypeKey || credentials.type == CredentialsConstants.appleTypeKey {
                    Auth.auth()
                    self.transitionLogin()
                } else {
                    self.isLoading = false
                    self.showLoginScreen()
                }
            } else {
                DispatchQueue.global().async {
                    self.isLoading = false
                    self.showLoginScreen()
                }
            }
        }
    }
    
    //MARK: - Helper Methods
    func showLoginScreen() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginScreen")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    func transitionLogin() {
        if let currentUser = Auth.auth().currentUser {
            if !currentUser.isAnonymous {
                MUserController.shared.fetchUser(googleRef: currentUser.uid) { didFind in
                    //Runs if user is reverifying account
                    if didFind {
                        guard let currentUser = MUserController.shared.currentUser else { return }
                        if currentUser.reports >= 30 {
                            guard let lastReport = currentUser.lastReport else { return }
                            let currentDate = Date()
                            
                            guard let timeInterval = Calendar.current.dateComponents([.day], from: lastReport, to: currentDate).day else {
                                self.isLoading = false
                                return }
                            let daysLeft = 30 - timeInterval
                            if daysLeft <= 0 {
                                currentUser.reports = 0
                                currentUser.lastReport = nil
                                MUserController.shared.saveUser(user: currentUser) {
                                    print("Reset User reports.")
                                }
                            } else {
                                self.isLoading = false
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewController(withIdentifier: "suspendedVC")
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
                        } else {
                            self.isLoading = false
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(identifier: "MainTabBarController")
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    //Runs if user needs to do aditional setup on account
                    else {
                        self.isLoading = false
                        let storyboard = UIStoryboard(name: "Login", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "requiredSetUp")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        } else {
            showLoginScreen()
        }
    }
    
}
