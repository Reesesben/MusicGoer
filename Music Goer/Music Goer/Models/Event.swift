//
//  Event.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import Foundation

class Event {
    let title: String
    let todos: [ToDo]
    let address: String
    let date: Date
    let members: [String]
    
    init(title: String, todos: [ToDo], address: String, date: Date, members: [String]) {
        self.title = title
        self.todos = todos
        self.address = address
        self.date = date
        self.members = members
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.title == rhs.title && lhs.address == rhs.address && lhs.date == rhs.date
    }
}
