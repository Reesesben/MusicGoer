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
        colorGradient()
        setupViews()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .currentContext
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorGradient()
        //view.backgroundColor = .black
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        //userImage.backgroundColor = .black
    }
    
    //MARK: - Helper Func
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: - Actions
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
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

    
