//
//  Event.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import Foundation
import CoreLocation

struct EventConstants {
    static let RecordTypeKey = "Event"
    static let eventIDKey = "EventID"
    static let titleKey = "Title"
    static let addressKey = "address"
    static let dateKey = "EventDate"
    static let membersKey = "MemberIDs"
    static let todosKey = "Todos"
    static let latitudeKey = "Latitude"
    static let longitudeKey = "Longitude"
}

class Event {
    var title: String
    let eventID: String
    var todos: [ToDo]
    var address: String
    var date: Date
    var members: [String]
    var latitude: Double?
    var longitude: Double?

    init(title: String, eventID: String = UUID().uuidString, todos: [ToDo], address: String, date: Date, members: [String], latitude: Double? = nil, longitude: Double? = nil) {

        self.title = title
        self.eventID = eventID
        self.todos = todos
        self.address = address
        self.date = date
        self.members = members
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.eventID == rhs.eventID && lhs.title == rhs.title
    }
}
