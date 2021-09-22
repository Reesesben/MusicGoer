//
//  FirstLoginViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/20/21.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var guestButton: UIButton!
    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet var loginWithEmailButton: UIButton!
    @IBOutlet var signUpEmailButton: UIButton!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        guestButton.layer.cornerRadius = guestButton.frame.height / 2
        loginWithEmailButton.layer.cornerRadius = loginWithEmailButton.frame.height / 2
        signUpEmailButton.layer.cornerRadius = signUpEmailButton.frame.height / 2
    }
    
    
    
    //MARK: - ACTIONS
    
    @IBAction func guestButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "MainTabBarController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
            // ...
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                  return
                }
                //performSegue(withIdentifier: "toDetailVC", sender: self)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
} // End of Class


