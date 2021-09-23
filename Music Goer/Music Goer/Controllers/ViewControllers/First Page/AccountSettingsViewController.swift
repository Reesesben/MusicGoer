//
//  AccountSettingsViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit
import Firebase
import FirebaseAuth
import MapKit
import GoogleSignIn


protocol PhotoSelectorDelegate: AnyObject {
    
    func didSelectNewImage(image: UIImage)
}

class AccountSettingsViewController: UIViewController, UIImagePickerControllerDelegate {
    //MARK: - IBOutlets
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var changePasswordButton: UIButton!
    @IBOutlet var deleteAccountButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
   
    //MARK: - Properties
    var currentUser: MUser?
    let imagePicker = UIImagePickerController()
    weak var delegate: PhotoSelectorDelegate?

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
        setupViews()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .currentContext
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //view.backgroundColor = .black
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        //userImage.backgroundColor = .black
    }
    
    //MARK: - Helper Functions
    func setupViews() {
        imagePicker.delegate = self
        
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.height / 2
       // userImage.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }//end of func

    func updateViews() {
        currentUser = MUserController.shared.currentUser
        guard let currentUser = currentUser,
        let firebaseUser = Auth.auth().currentUser else { return }
        loadViewIfNeeded()
        userName.text = currentUser.userName
        emailLabel.text = firebaseUser.email
        userImage.image = UIImage(data: currentUser.userImage)
        userImage.layer.cornerRadius = userImage.frame.height / 2
        
    }

    
    //MARK: - Actions
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        guard let currentUser = currentUser else { return }
        MUserController.shared.deleteUser(user: currentUser) { didFinish in
            if didFinish {
                print("Sucessfully deleted user")
                CredentialsController.shared.deletePersistentStore()
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "LoginScreen")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                if CredentialsController.shared.currentCredentials?.type == CredentialsConstants.googleTypeKey {
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                // Create Google Sign In configuration object.
                let config = GIDConfiguration(clientID: clientID)
                // Start the sign in flow!
                GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
                    if let error = error {
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        return
                    }
                    guard let authentication = user?.authentication,
                        let idToken = authentication.idToken else {return}
                    
                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: authentication.accessToken)
                    
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                            return
                        }
                        guard let user = Auth.auth().currentUser else { return }
                        user.delete { error in
                            if let error = error {
                                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                            }
                            do {
                             try Auth.auth().signOut()
                            } catch {
                                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                            }
                            CredentialsController.shared.deletePersistentStore()
                            print("User Sucessfully deleted")
                        }
                    }
                    }
                } else {
                print("It didn't work and I don't know why.")
                }
            }
            
        }
    }
    
    @IBAction func changePasswordButtonTapped(_ sender: Any) {
        print("lol this button doesn't do anything")
        }
    
    @IBAction func changeImageButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a photo", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openGallery()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        
        present(alert, animated: true)
    }
    
    func presentNoAccessAlert() {
        let alert = UIAlertController(title: "No Access", message: "Please allow access to use this feature.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Back", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}//end of class

extension AccountSettingsViewController: UINavigationControllerDelegate {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true)
            
        } else {
            self.presentNoAccessAlert()
        }
        
    }//end of func
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
            
        } else {
            self.presentNoAccessAlert()
        }
        
    }//end of func
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            userImage.image = editedImage
            selectImageButton.setTitle("Change Image", for: .normal)
            delegate?.didSelectNewImage(image: editedImage)
        }
        else if let pickedImage = info[.originalImage] as? UIImage {
            userImage.image = pickedImage
            selectImageButton.setTitle("Change Image", for: .normal)
            userImage.clipsToBounds = true
            userImage.layer.cornerRadius = userImage.frame.height / 2
            delegate?.didSelectNewImage(image: pickedImage)        }
        picker.dismiss(animated: true)
        
    }//end of func
}
