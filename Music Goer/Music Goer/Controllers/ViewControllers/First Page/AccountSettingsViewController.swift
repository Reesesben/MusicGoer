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
        colorGradient()
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
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    
    //MARK: - Actions
    @IBAction func signOutButtonTapped(_ sender: Any) {
        CredentialsController.shared.deletePersistentStore()
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "LoginScreen")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } catch {
            displayError(title: "Error signing out", Body: "An error occured trying to sign out please try again later.")
        }
        
    }
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
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                let vc = storyboard.instantiateViewController(identifier: "LoginScreen")
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                            }
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
        //Initialize Image Picker.
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        //Create an alert controler to check where the image is coming from.
        let alertController = UIAlertController(title: "Import image", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Take a Photo", style: .default) { _ in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true)
        }
        let photoLibrary = UIAlertAction(title: "From Library", style: .default) { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //Check if device has the options available and add them to the Alert Controller
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(camera)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(photoLibrary)
        }
        //Add the cancle action no matter what.
        alertController.addAction(cancel)
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        //Present the alert Controller to the User
        self.present(alertController, animated: true)
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
            print("I am running")
            
        } else {
            self.presentNoAccessAlert()
        }
        
    }//end of func
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var newImage = UIImage()
        
        if let editedImage = info[.editedImage] as? UIImage {
            userImage.image = editedImage
            selectImageButton.setTitle("Change Image", for: .normal)
            newImage = editedImage
            delegate?.didSelectNewImage(image: editedImage)
        }
        else if let pickedImage = info[.originalImage] as? UIImage {
            userImage.image = pickedImage
            selectImageButton.setTitle("Change Image", for: .normal)
            userImage.clipsToBounds = true
            userImage.layer.cornerRadius = userImage.frame.height / 2
            newImage = pickedImage
            delegate?.didSelectNewImage(image: pickedImage)        }
        picker.dismiss(animated: true)
        
        guard let currentUser = MUserController.shared.currentUser,
        let imageData = newImage.jpegData(compressionQuality: 0.5) else { return }
        
        currentUser.userImage = imageData
        MUserController.shared.saveUser(user: currentUser) {
            print("Image was updated in Firebase")
        }
        
    }//end of func
}
