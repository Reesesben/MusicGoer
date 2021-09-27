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
import AuthenticationServices
import CryptoKit
import FirebaseAuthUI

class LoginViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var guestButton: UIButton!
    @IBOutlet weak var googleSignIn: GIDSignInButton!
    @IBOutlet var loginWithEmailButton: UIButton!
    @IBOutlet var signUpEmailButton: UIButton!
    @IBOutlet weak var AppleLogin: UIStackView!
    
    
    
    //MARK: - Lifecycles
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorGradient()
        guestButton.layer.cornerRadius = guestButton.frame.height / 2
        loginWithEmailButton.layer.cornerRadius = loginWithEmailButton.frame.height / 2
        signUpEmailButton.layer.cornerRadius = signUpEmailButton.frame.height / 2
        googleSignIn.layer.cornerRadius = googleSignIn.frame.height / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSignInButton()
        colorGradient()
//        guestButton.gradientButton("𝙂𝙪𝙚𝙨𝙩 𝙎𝙞𝙜𝙣 𝙄𝙣", startColor: .black, endColor: .black)
//        loginWithEmailButton.gradientButton("𝙇𝙤𝙜𝙞𝙣 𝙒𝙞𝙩𝙝 𝙀𝙢𝙖𝙞𝙡", startColor: .black, endColor: .black)
//        signUpEmailButton.gradientButton("𝙎𝙞𝙜𝙣 𝙐𝙥 𝙒𝙞𝙩𝙝 𝙀𝙢𝙖𝙞𝙡", startColor: .black, endColor: .black)
        guestButton.applyGradient(colors: [CGColor.init(red: 0.5, green: 0, blue: 0.5, alpha: 1), CGColor.init(red: 0.125, green: 0.125, blue: 0.75, alpha: 1), CGColor.init(red: 0, green: 0.5, blue: 0.5, alpha: 1)])
        loginWithEmailButton.applyGradient(colors: [CGColor.init(red: 0.5, green: 0, blue: 0.5, alpha: 1), CGColor.init(red: 0.125, green: 0.125, blue: 0.75, alpha: 1), CGColor.init(red: 0, green: 0.5, blue: 0.5, alpha: 1)])
        signUpEmailButton.applyGradient(colors: [CGColor.init(red: 0.5, green: 0, blue: 0.5, alpha: 1), CGColor.init(red: 0.125, green: 0.125, blue: 0.75, alpha: 1), CGColor.init(red: 0, green: 0.5, blue: 0.5, alpha: 1)])
         CredentialsController.shared.loadFromPresistenceStore { sucess in
            if sucess {
                guard let credentials = CredentialsController.shared.currentCredentials else { return }
                if credentials.type == CredentialsConstants.emailTypeKey {
                    guard let email = credentials.email,
                          let password = credentials.password else { return }
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let error = error {
                            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        }
                        DispatchQueue.main.async {
                            self.transitionLogin()
                        }
                    }
                } else if credentials.type == CredentialsConstants.googleTypeKey {
                    Auth.auth()
                    self.transitionLogin()
                }
            }
        }
        navigationController?.navigationBar.isHidden = true
    }
    //MARK: - Apple sign in
    func setupSignInButton() {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
        self.AppleLogin.addArrangedSubview(button)
//        button.center = view.center
//        view.addSubview(button)
    }
    
    @objc func handleSignInWithAppleTapped() {
        performSignIn()
    }
    
    func performSignIn() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }

    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName,.email]
        
        let nonce = randomNonceString()
        request.nonce = randomNonceString()
        currentNonce = nonce
        
        
        return request
    }
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.red.cgColor, UIColor.red.cgColor, UIColor.systemOrange.cgColor, UIColor.yellow.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
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
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
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
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return
                }
                
                CredentialsController.shared.currentCredentials = Credentials(email: nil, password: nil, type: CredentialsConstants.googleTypeKey)
                CredentialsController.shared.saveToPresistenceStore()
                transitionLogin()
            }
        }
    }
    
    //MARK: - Helper Methods
    func transitionLogin() {
        if let currentUser = Auth.auth().currentUser {
            if !currentUser.isAnonymous {
                MUserController.shared.fetchUser(googleRef: currentUser.uid) { didFind in
                    //Runs if user is reverifying account
                    if didFind {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "MainTabBarController")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                    //Runs if user needs to do aditional setup on account
                    else {
                        let storyboard = UIStoryboard(name: "Login", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "requiredSetUp")
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
} // End of Class

extension UIButton {
    func applyGradient(colors: [CGColor]) {
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
}
//MARK: - Apple Login extension

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to Serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential) { authDataResult, error in
                if let user = authDataResult?.user {
                    print("Nice! You're signed in as \(user.uid), email: \(user.email ?? "unknown")")
                }
            }
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}


// Unhashed nonce.
fileprivate var currentNonce: String?

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    return String(format: "%02x", $0)
  }.joined()

  return hashString
}
