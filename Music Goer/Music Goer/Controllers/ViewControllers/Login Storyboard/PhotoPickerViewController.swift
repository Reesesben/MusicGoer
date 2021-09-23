//
//  PhotoPickerViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/21/21.
//

import UIKit
import AVFoundation

protocol photoPickerDelegate {
    func didSelectNewImage(image: UIImage)
}

class PhotoPickerViewController: UIViewController, UIImagePickerControllerDelegate {
    //MARK: - IBOutlets
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var userImage: UIImageView!
    
    //MARK: - Properties
    var imagePicker = UIImagePickerController()
    var delegate: photoPickerDelegate?
    
    //MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    //MARK: - Actions
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
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
    
    //MARK: - Helper Methods
    
    func setupViews() {
        imagePicker.delegate = self
        
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
    }//end of func
    
    func presentNoAccessAlert() {
        let alert = UIAlertController(title: "No Access", message: "Please allow access to use this feature.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Back", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}//end of class

extension PhotoPickerViewController: UINavigationControllerDelegate {
    
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
            selectImageButton.setTitle("", for: .normal)
            delegate?.didSelectNewImage(image: editedImage)
        }
        else if let pickedImage = info[.originalImage] as? UIImage {
            userImage.image = pickedImage
            selectImageButton.setTitle("", for: .normal)
            userImage.clipsToBounds = true
            userImage.layer.cornerRadius = userImage.frame.height / 2
            delegate?.didSelectNewImage(image: pickedImage)        }
        picker.dismiss(animated: true)
        
    }//end of func
   
}//end of extension

    
