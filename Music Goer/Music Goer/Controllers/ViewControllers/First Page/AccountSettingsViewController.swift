//
//  AccountSettingsViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit
import FirebaseAuth

class AccountSettingsViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var changePasswordButton: UIButton!
    @IBOutlet var deleteAccountButton: UIButton!
    
    //MARK: - Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if MUserController.shared.currentUser == nil {
            let alert = UIAlertController(title: "You are not logged in!", message: "Oops your not logged in! This portion of the app won't work without an account.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .default) { _ in
                self.tabBarController?.selectedIndex = 1
            }
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    //MARK: - Properties
    var currentUser: MUser?
    
    
    //MARK: - Helper Methods
    func updateViews() {
        currentUser = MUserController.shared.currentUser
        guard let currentUser = currentUser,
        let firebaseUser = Auth.auth().currentUser else { return }
        userName.text = currentUser.userName
        emailLabel.text = firebaseUser.email
        userImage.image = UIImage(data: currentUser.userImage)
    }
    
    //MARK: - Actions
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        guard let currentUser = currentUser else { return }
        MUserController.shared.deleteUser(user: currentUser) { didFinish in
            if didFinish {
                print("Sucessfully deleted user")
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "LoginScreen")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                print("It didn't work and I don't know why.")
            }
            
        }
    }
    
    @IBAction func changePasswordButtonTapped(_ sender: Any) {
        print("lol this button doesn't do anything")
        }
}
