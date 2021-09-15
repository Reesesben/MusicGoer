//
//  File.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit

class ToDo {
    let image: UIImage
    let title: String
    let category: String
    let dueDate: Date?
    let isComplete: Bool

    init(image: UIImage, title: String, category: String, dueDate: Date?, isComplete: Bool) {
        self.image = image
        self.title = title
        self.category = category
        self.dueDate = dueDate
        self.isComplete = isComplete
    }
    
}
