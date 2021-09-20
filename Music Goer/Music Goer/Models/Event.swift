//
//  Event.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import Foundation
import CoreLocation

class Event {
    let title: String
    var todos: [ToDo]
    let address: CLLocationCoordinate2D
    let date: Date
    let members: [String]
    
    init(title: String, todos: [ToDo], address: CLLocationCoordinate2D, date: Date, members: [String]) {
        self.title = title
        self.todos = todos
        self.address = address
        self.date = date
        self.members = members
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.title == rhs.title && lhs.date == rhs.date
    }
}
