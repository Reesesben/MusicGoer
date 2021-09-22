//
//  UserChatHeadCollectionViewCell.swift
//  Music Goer
//
//  Created by Delstun McCray on 9/21/21.
//

import UIKit

class UserChatHeadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    var character: Character? {
        didSet {
            layoutIfNeeded()
            displayImageFor()
        }
    }
    
    func displayImageFor() {
        guard let character = character else { return }
        //let image = UIImage(named: character.photo)
        userImageView.image = UIImage(named: character.photo)

        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.layer.masksToBounds = true

    }
}
