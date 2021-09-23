//
//  UserChatHeadCollectionViewCell.swift
//  Music Goer
//
//  Created by Delstun McCray on 9/21/21.
//

import UIKit

class UserChatHeadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var characterImageView: UIImageView!
    
    var character: fakeUser? {
        didSet {
            layoutIfNeeded()
            displayImageFor()
        }
    }
    
    func displayImageFor() {
        guard let character = character else { return }
        //let image = UIImage(named: character.photo)
        characterImageView.image = UIImage(named: character.photo)

        characterImageView.contentMode = .scaleAspectFill
        characterImageView.layer.cornerRadius = 50
        characterImageView.layer.masksToBounds = true

    }
}
