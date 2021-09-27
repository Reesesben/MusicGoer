//
//  RoundedImage.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/27/21.
//

import UIKit

class RoundedImage: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}
