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
    
    func displayImageFor() {
        guard let member = member else { return }
        //let image = UIImage(named: character.photo)
        characterImageView.image = member

        characterImageView.contentMode = .scaleAspectFill
        characterImageView.layer.cornerRadius = 50
        characterImageView.layer.masksToBounds = true

    }
}
