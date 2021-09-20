//
//  EventController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit

class EventController {
    static var shared = EventController()
    
    var events: [Event] = []
    var currentEventIndex: Int = 0
    
    //MARK: - CRUD Functions
    func createEvent(title: String, address: String, date: Date, members: [String]) {
        events.append(Event(title: title, todos: [], address: address, date: date, members: members))
    }
    
    func updateEvent(event: Event) {
        // Update firebase record here
    }
    
    func fetchEvents(){
     //Do Fire base fetch here
    }
    
    func deleteEvent(event: Event) {
        guard let index = events.firstIndex(of: event) else { return }
        events.remove(at: index)
    }
    
    //MARK: - TableView Helpers
    func moveEvent(event: Event, newIndex: Int) {
        guard let index = events.firstIndex(of: event) else { return }
        events.remove(at: index)
        events.insert(event, at: newIndex)
    }
    
    //MARK: - ToDo's
    
    func createToDo(image: UIImage?, title: String, category: String, address: String, date: Date, members: [String]) {
        events[currentEventIndex].todos.append(ToDo(image: image, title: title, category: category, dueDate: date, isComplete: false))
    }    
}
