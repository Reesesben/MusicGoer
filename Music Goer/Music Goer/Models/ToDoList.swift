//
//  ToDoList.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation

class Journal: Codable {
    var title: String
    var name: String
    var date: Date
    var entries: [Entry]
    let uuid: String
    
    init(title: String, name: String, date: Date, entries: [Entry] = [], uuid: String = UUID().uuidString) {
        self.title = title
        self.name = name
        self.date = date
        self.entries = entries
        self.uuid = uuid
    }
    
}

extension Journal: Equatable {
    static func == (lhs: Journal, rhs: Journal) -> Bool{
        return lhs.uuid == rhs.uuid
        
    }
}
