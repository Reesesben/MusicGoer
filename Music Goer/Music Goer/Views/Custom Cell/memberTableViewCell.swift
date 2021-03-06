//
//  SearchTableViewCell.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/24/21.
//

import UIKit

class memberTableViewCell: UITableViewCell {
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
    /**
     Updates results cell with user Image and Username and rounds image,
             
        - Parameter with: An MUser object that is the users information you want displayed in the cell
     */
    func updateCell(with user: MUser) {
        userImage.image = UIImage(data: user.userImage)
        userName.text = user.userName
    }
    
}
