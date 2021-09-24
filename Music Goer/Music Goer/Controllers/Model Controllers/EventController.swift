//
//  EventController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit
import CoreLocation
import Firebase

class EventController {
    static var shared = EventController()
    
    let db = Firestore.firestore()
    var dateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateformatter
    }
    
    var events: [Event] = []
    
    //MARK: - CRUD Functions
    func createEvent(title: String, address: String, date: Date, members: [String], completion: @escaping () -> Void) {
        let newEvent = Event(title: title, todos: [], address: address, date: date, members: members)
        updateEvent(event: newEvent, completion: {
            print("Event Created Sucessfully")
            return completion()
        })
    }
    
    func updateEvent(event: Event, completion: @escaping ()-> Void) {
        let eventRef = db.collection(EventConstants.RecordTypeKey).document(event.eventID)
        eventRef.setData([EventConstants.eventIDKey : event.eventID,
                          EventConstants.titleKey : event.title,
                          EventConstants.addressKey : event.address,
                          EventConstants.dateKey : dateFormatter.string(from: event.date),
                          EventConstants.membersKey : event.members], merge: true)
        for todo in event.todos {
            let todoRef = db.collection(EventConstants.RecordTypeKey).document(event.eventID).collection(EventConstants.todosKey).document(todo.todoID)
            todoRef.setData([ToDoConstants.todoIDKey: todo.todoID,
                             ToDoConstants.titleKey : todo.title,
                             ToDoConstants.dueDate : dateFormatter.string(from: todo.dueDate),
                             ToDoConstants.isComplete : todo.isComplete,
                             ToDoConstants.person : todo.person], merge: true)
        }
        
        print("Event saved sucessfully")
        return completion()
    }
    
    func fetchEvents(completion: @escaping (Bool) -> Void){
        guard let currentUser = MUserController.shared.currentUser else { return }
        db.collection(EventConstants.RecordTypeKey).whereField(EventConstants.membersKey, arrayContains: currentUser.userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
            
            if let snapshot = snapshot {
                self.events = []
                
                for doc in snapshot.documents {
                    let eventData = doc.data()
                    
                    guard let eventID = eventData[EventConstants.eventIDKey] as? String,
                          let title = eventData[EventConstants.titleKey] as? String,
                          let address = eventData[EventConstants.addressKey] as? String,
                          let date = eventData[EventConstants.dateKey] as?
                            String,
                          let members = eventData[EventConstants.membersKey] as? [String] else { return completion(false)}
                    
                    guard let newDate = self.dateFormatter.date(from: date) else { return }
                    self.events.append(Event(title: title, eventID: eventID, todos: [], address: address, date: newDate, members: members))
                }
                return completion(true)
            } else { return completion(false) }
        }
    }
    
    func fetchTodos(for event: Event, completion: @escaping () -> Void) {
        db.collection(EventConstants.RecordTypeKey).document(event.eventID).collection(EventConstants.todosKey).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion()
            }
            
            if let snapshot = snapshot {
                for doc in snapshot.documents {
                    let todoData = doc.data()
                    guard let title = todoData[ToDoConstants.titleKey] as? String,
                          let person = todoData[ToDoConstants.person] as? String,
                          let dueDate = todoData[ToDoConstants.dueDate] as? String,
                          let isComplete = todoData[ToDoConstants.isComplete] as? Bool,
                          let id = todoData[ToDoConstants.todoIDKey] as? String,
                          let newDueDate = self.dateFormatter.date(from: dueDate) else { return }
                    event.todos.append(ToDo(todoID: id,title: title, person: person, dueDate: newDueDate, isComplete: isComplete))
                }
                return completion()
            }
        }
    }
    
    
    func leaveEvent(event: Event, completion: @escaping () -> Void) {
        guard let currentUser = MUserController.shared.currentUser,
        let index = event.members.firstIndex(of: currentUser.userID) else { return }
        event.members.remove(at: index)
        updateEvent(event: event) {
            return completion()
        }
    }
    
    func deleteEvent(event: Event, completion: @escaping (Bool) -> Void) {
        guard let index = events.firstIndex(of: event) else { return }
        db.collection(EventConstants.RecordTypeKey).document(event.eventID).delete() { error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
            self.events.remove(at: index)
            return completion(true)
        }
    }
    
    func getPhoto(userRefs: [String], completion: @escaping ([UIImage]) -> Void) {
        var userImages: [UIImage] = []
        print("Attempting to fetch Photos")
        db.collection(UserConstants.recordTypeKey).whereField(UserConstants.userIDKey, in: userRefs).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                print("failed to fetch photos")
                return completion([UIImage()])
            }
            
            if let snapshot = snapshot {
                print("snapshot recieved")
                for doc in snapshot.documents {
                    print(snapshot.documents.count)
                    let userData = doc.data()
                    guard let imageData = userData[UserConstants.imageDataKey] as? Data,
                          let userImage = UIImage(data: imageData) else { return completion([UIImage()])}
                    userImages.append(userImage)
                }
             return completion(userImages)
            } else { return completion([UIImage()]) }
        }
        return completion(userImages)
    }
    
    //MARK: - ToDo's
    func createToDo(title: String, person: String, date: Date, event: Event, completion: @escaping () -> Void) {
        event.todos.append(ToDo(title: title, person: person, dueDate: date, isComplete: false))
        updateEvent(event: event, completion: {
            print("Sucessfully created ToDo")
            return completion()
        })
    }
    
    func deleteToDo (event: Event, todo: ToDo, completion: @escaping (Bool) -> Void) {
        guard let index = event.todos.firstIndex(of: todo) else { return }
        db.collection(EventConstants.RecordTypeKey).document(event.eventID).collection(EventConstants.todosKey).document(todo.todoID).delete() { error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
            event.todos.remove(at: index)
            return completion(true)
        }
    }
    
}
