//
//  UserChatHeadCollectionViewCell.swift
//  Music Goer
//
//  Created by Delstun McCray on 9/21/21.
//

import UIKit

class UserChatHeadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var characterImageView: UIImageView!
    
    var member: UIImage? {
        didSet {
            layoutIfNeeded()
            displayImageFor()
        }
    }
    ///Displays image in collection view of user and rounds it.
    func displayImageFor() {
        guard let member = member else { return }
        //let image = UIImage(named: character.photo)
        characterImageView.image = member

        characterImageView.contentMode = .scaleAspectFill
        characterImageView.layer.cornerRadius = characterImageView.frame.height / 2
        characterImageView.layer.masksToBounds = true

    }
}

