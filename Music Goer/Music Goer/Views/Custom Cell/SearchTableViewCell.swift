//
//  SearchTableViewCell.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/24/21.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    
    //MARK: - Cell Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = UIImage()
        userName.text = ""
    }
    
    //MARK: - Helper Methods
    func updateCell(with user: MUser) {
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.image = UIImage(data: user.userImage)
        userName.text = user.userName
    }
    
}
