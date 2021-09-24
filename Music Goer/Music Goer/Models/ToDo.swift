//
//  File.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit

struct ToDoConstants {
    static let RecordTypeKey = "Todo"
    static let todoIDKey = "EventID"
    static let titleKey = "Title"
    static let person = "Person"
    static let dueDate = "dueDate"
    static let isComplete = "isComplete"
}

class ToDo {
    let todoID: String
    var title: String
    var person: String
    var dueDate: Date
    var isComplete: Bool

    init(todoID: String = UUID().uuidString, title: String, person: String, dueDate: Date, isComplete: Bool) {
        self.todoID = todoID
        self.title = title
        self.person = person
        self.dueDate = dueDate
        self.isComplete = isComplete
    }
    
}

extension ToDo: Equatable {
    static func == (lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.title == rhs.title && lhs.person == rhs.person && rhs.todoID == lhs.todoID
    }
}
