//
//  EventController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseFirestore

class EventController {
    static var shared = EventController()
    
    let db = Firestore.firestore()
    var dateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateformatter
    }
    
    ///SOT holding all events the user has joined.
    var events: [Event] = []
    
    //MARK: - CRUD Functions
    
    /**
     Creates an event and saves it to the database.
     
     - Parameter title: Title of the event to organize events in the events tab.
     - Parameter date: Date the event will take place
     - Parameter members: Array of userID's containing all members who have accepted the invitaion to the event.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func createEvent(title: String, date: Date, members: [String], completion: @escaping (Bool) -> Void) {
        guard let admin = members.first else { return }
        var toInvite = members
        toInvite.remove(at: 0)
        let newEvent = Event(title: title, todos: [], date: date, members: [admin])
        if toInvite.count > 0 {
            MUserController.shared.inviteUsers(memberRefs: toInvite, eventID: newEvent.eventID, completion: { sucess in
                if sucess {
                    self.updateEvent(event: newEvent, completion: {
                        print("Event Created Sucessfully")
                        self.events.append(newEvent)
                        return completion(true)
                    })
                } else {
                    return completion(false)
                }
            })
        }
    }
    
    /**
     Saves an Event to the Firestore Database
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter event: The event to save changes to.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func updateEvent(event: Event, completion: @escaping ()-> Void) {
        let eventRef = db.collection(EventConstants.RecordTypeKey).document(event.eventID)
        eventRef.setData([EventConstants.eventIDKey : event.eventID,
                          EventConstants.titleKey : event.title,
                          EventConstants.dateKey : dateFormatter.string(from: event.date),
                          EventConstants.latitudeKey : event.latitude ?? 0.0,
                          EventConstants.longitudeKey : event.longitude ?? 0.0,
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
    
    /**
     Fetches all events with the current users ID and saves them to the local SOT.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
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
                          let date = eventData[EventConstants.dateKey] as?
                            String,
                          let members = eventData[EventConstants.membersKey] as? [String] else { return completion(false)}
                    
                    var eventLatitude: Double? = nil
                    if let latitude = eventData[EventConstants.latitudeKey] as? Double {
                        eventLatitude = latitude
                    }
                    var eventLongitude: Double? = nil
                    if let longitude = eventData[EventConstants.longitudeKey] as? Double {
                        eventLongitude = longitude
                    }
                    
                    guard let newDate = self.dateFormatter.date(from: date) else { return }
                    self.events.append(Event(title: title, eventID: eventID, todos: [], date: newDate, members: members, latitude: eventLatitude, longitude: eventLongitude))
                }
                return completion(true)
            } else { return completion(false) }
        }
    }
    
    /**
     Fetches a specific event with event ID
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter with: an array of event ID's to look for.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func fetchEvents(with IDs: [String],completion: @escaping ([Event]?, Bool) -> Void){
        db.collection(EventConstants.RecordTypeKey).whereField(EventConstants.eventIDKey, in: IDs).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(nil, false)
            }
            
            if let snapshot = snapshot {
                var pending: [Event] = []
                
                for doc in snapshot.documents {
                    let eventData = doc.data()
                    
                    guard let eventID = eventData[EventConstants.eventIDKey] as? String,
                          let title = eventData[EventConstants.titleKey] as? String,
                          let date = eventData[EventConstants.dateKey] as?
                            String,
                          let members = eventData[EventConstants.membersKey] as? [String] else { return completion(nil, false)}
                    
                    var eventLatitude: Double? = nil
                    if let latitude = eventData[EventConstants.latitudeKey] as? Double {
                        eventLatitude = latitude
                    }
                    var eventLongitude: Double? = nil
                    if let longitude = eventData[EventConstants.longitudeKey] as? Double {
                        eventLongitude = longitude
                    }
                    
                    guard let newDate = self.dateFormatter.date(from: date) else { return }
                    pending.append(Event(title: title, eventID: eventID, todos: [], date: newDate, members: members, latitude: eventLatitude, longitude: eventLongitude))
                }
                return completion(pending, true)
            } else { return completion(nil, false) }
        }
    }
    
    /**
     Fetches all Todos for a given event, and adds them to the events todo array.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter event: event to retrieve and place todos in.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func fetchTodos(for event: Event, completion: @escaping () -> Void) {
        db.collection(EventConstants.RecordTypeKey).document(event.eventID).collection(EventConstants.todosKey).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion()
            }
            event.todos = []
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
    
    /**
     Removes current user from members list in event.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter event: Event to remove user from.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func leaveEvent(event: Event, completion: @escaping () -> Void) {
        guard let currentUser = MUserController.shared.currentUser,
              let eIndex = events.firstIndex(of: event),
              let index = event.members.firstIndex(of: currentUser.userID) else { return }
        event.members.remove(at: index)
        events.remove(at: eIndex)
        updateEvent(event: event) {
            return completion()
        }
    }
    
    /**
     Removes an event from the Firestore Database.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter event: Event to delete from Firebase
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
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
    
    /**
     Takes in userIDs and gets user photos for each.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter userRefs: Array of UserID's to fetch photos for.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons. Returns array of UIImages
     */
    func getPhoto(userRefs: [String], completion: @escaping ([UIImage]) -> Void) {
        var userImages: [UIImage] = []
        for _ in userRefs {
            userImages.append(UIImage())
        }
        print("Attempting to fetch Photos")
        print("-----------------------")
        for member in userRefs {
            print(member)
        }
        print("-----------------------")
        db.collection(UserConstants.recordTypeKey).whereField(UserConstants.userIDKey, in: userRefs).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                print("failed to fetch photos")
                return completion([UIImage()])
            }
            print("-----------------------")
            if let snapshot = snapshot {
                for doc in snapshot.documents {
                    let userData = doc.data()
                    guard let imageData = userData[UserConstants.imageDataKey] as? Data,
                          let userID = userData[UserConstants.userIDKey] as? String,
                          let userImage = UIImage(data: imageData) else { return completion([UIImage()])}
                    guard let index = userRefs.firstIndex(of: userID) else { return }
                    userImages.remove(at: index)
                    userImages.insert(userImage, at: index)
                }
                print("-----------------------")
                return completion(userImages)
            } else { return completion([UIImage()]) }
        }
        return completion(userImages)
    }
    
    //MARK: - ToDo's
    /**
     Adds todo to specific event.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter title: title for todo
     - Parameter person: person in charge of todo
     - Parameter date: date to complete todo by.
     - Parameter event: event todo is a part of
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func createToDo(title: String, person: String, date: Date, event: Event, completion: @escaping () -> Void) {
        event.todos.append(ToDo(title: title, person: person, dueDate: date, isComplete: false))
        updateEvent(event: event, completion: {
            print("Sucessfully created ToDo")
            return completion()
        })
    }
    /**
     Removes todo from specific event.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter event: event todo is a part of
     - Parameter todo: specific todo to remove from event.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
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
