//
//  UserController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/21/21.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MUserController {
    /// Singleton for usercontroller to keep data consistent
    static var shared = MUserController()
    ///Current user logged into the database
    var currentUser: MUser?
    ///Reference to the main firestore where the app reads and writes data
    let db = Firestore.firestore()
    
    var dateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateformatter
    }
    
    //MARK: - CRUD Functions
    /**
     Method creates a user and saves information to the databse stored along side the google Auth user.
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter userName: The display name for the user. Other users will search this in the app when adding users to events
     - Parameter userImageData: Data for the users profile picture
     - Parameter googleRef: A record reference so that the user can be fetched  from the authenticated account
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func createUser(userName: String, userImage: Data, googleRef: String, completion: @escaping (Bool) -> Void) {
        currentUser = MUser(userName: userName, userImageData: userImage, googleRef: googleRef, lastReport: nil)
        guard let currentUser = currentUser else {return completion(false)}
        saveUser(user: currentUser, completion: {
            print("User Created Sucessfully")
            return completion(true)
        })
    }
    
    /**
     Saves all changes to user data to the firestore database
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter user: An MUser object that is the user  you would like saved to the database
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func saveUser(user: MUser, completion: @escaping () -> Void) {
        let userRef = db.collection(UserConstants.recordTypeKey).document(user.userID)
        userRef.setData([UserConstants.userIDKey : user.userID,
                         UserConstants.userNameKey : user.userName,
                         UserConstants.imageDataKey : user.userImage,
                         UserConstants.googleRefKey : user.googleRef,
                         UserConstants.pendingKey : user.pending,
                         UserConstants.blockedKey : user.blocked,
                         UserConstants.reportsKey : user.reports,], merge: true)
        
        if let lastReport = user.lastReport {
            let date = dateFormatter.string(from: lastReport)
            userRef.setData([UserConstants.lastReportKey : date], merge: true)
        }
        print("User saved sucessfully")
        return completion()
    }
    
    /**
     Fetches a specific users data from a google Reference, fetched user is assigned to the current user object in MUserController
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter googleRef: A record reference so that the user can be fetched  from the authenticated account
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func fetchUser(googleRef: String, completion: @escaping (Bool) -> Void) {
        db.collection(UserConstants.recordTypeKey).whereField(UserConstants.googleRefKey, isEqualTo: googleRef).limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
            
            if let snapshot = snapshot {
                guard let doc = snapshot.documents.first else { return completion(false)}
                let userData = doc.data()
                guard let userID = userData[UserConstants.userIDKey] as? String,
                      let userName = userData[UserConstants.userNameKey] as? String,
                      let imageData = userData[UserConstants.imageDataKey] as? Data,
                      let googleRef = userData[UserConstants.googleRefKey] as? String,
                      let pending = userData[UserConstants.pendingKey] as? [String],
                      let blocked = userData[UserConstants.blockedKey] as? [String],
                      let reports = userData[UserConstants.reportsKey] as? Int else { return completion(false)}
                
                var date: Date? = nil
                if let lastReport = userData[UserConstants.lastReportKey] as? String {
                    date = self.dateFormatter.date(from: lastReport)
                }
                
                
                self.currentUser = MUser(userID: userID, userName: userName, userImageData: imageData, googleRef: googleRef, pending: pending, reports: reports, lastReport: date, blocked: blocked)
                return completion(true)
            } else { return completion(false) }
        }
    }
    
    /**
     Searches for any users who match a specific string in their username
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter userName: The string that contains the username to look for.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func searchUser(userName: String, completion: @escaping ([MUser]?, Bool?) -> Void) {
        db.collection(UserConstants.recordTypeKey).whereField(UserConstants.userNameKey, isGreaterThanOrEqualTo: userName).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(nil, true)
            }
            var users: [MUser] = []
            if let snapshot = snapshot {
                for doc in snapshot.documents {
                    let userData = doc.data()
                    guard let userID = userData[UserConstants.userIDKey] as? String,
                          let userName = userData[UserConstants.userNameKey] as? String,
                          let imageData = userData[UserConstants.imageDataKey] as? Data,
                          let googleRef = userData[UserConstants.googleRefKey] as? String,
                          let pending = userData[UserConstants.pendingKey] as? [String],
                          let blocked = userData[UserConstants.blockedKey] as? [String],
                          let reports = userData[UserConstants.reportsKey] as? Int else { return completion(nil, true)}
                    
                    var date: Date? = nil
                    if let lastReport = userData[UserConstants.lastReportKey] as? String {
                        date = self.dateFormatter.date(from: lastReport)
                    }
                    
                    users.append(MUser(userID: userID, userName: userName, userImageData: imageData, googleRef: googleRef, pending: pending, reports: reports, lastReport: date, blocked: blocked))
                }
                return completion(users, nil)
            } else { return completion(nil, false) }
        }
    }
    
    /**
     Gets MUser Objects from userId's
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter userNames: an array of strings containing userId's for usersers to fetch.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func getUsers(userNames: [String], completion: @escaping ([MUser]?, Bool?) -> Void) {
        db.collection(UserConstants.recordTypeKey).whereField(UserConstants.userIDKey, in: userNames).getDocuments { snapshot, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(nil, true)
            }
            var users: [MUser] = []
            if let snapshot = snapshot {
                for doc in snapshot.documents {
                    let userData = doc.data()
                    guard let userID = userData[UserConstants.userIDKey] as? String,
                          let userName = userData[UserConstants.userNameKey] as? String,
                          let imageData = userData[UserConstants.imageDataKey] as? Data,
                          let googleRef = userData[UserConstants.googleRefKey] as? String,
                          let pending = userData[UserConstants.pendingKey] as? [String],
                          let blocked = userData[UserConstants.blockedKey] as? [String],
                          let reports = userData[UserConstants.reportsKey] as? Int else { return completion(nil, true)}
                    
                    var date: Date? = nil
                    if let lastReport = userData[UserConstants.lastReportKey] as? String {
                        date = self.dateFormatter.date(from: lastReport)
                    }
                    users.append(MUser(userID: userID, userName: userName, userImageData: imageData, googleRef: googleRef, pending: pending, reports: reports, lastReport: date, blocked: blocked))
                }
                for user in users {
                    guard let newIndex = userNames.firstIndex(of: user.userID),
                          let index = users.firstIndex(of: user) else { return }
                    users.remove(at: index)
                    users.insert(user, at: newIndex)
                }
                return completion(users, nil)
            } else { return completion(nil, false) }
        }
    }
    /**
     Adds event ID to each firebase record with userID in memberRefs
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter memberRefs: An MUser object that is the user  you would like saved to the database
     - Parameter eventID: Event id of event to invite users to.
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func inviteUsers(memberRefs: [String], eventID: String, completion: @escaping (Bool) -> Void) {
        MUserController.shared.getUsers(userNames: memberRefs) { users, error in
            if error != nil {
                return completion(false)
            }
            
            guard let users = users else { return }
            for user in users {
                if !user.pending.contains(eventID) {
                    user.pending.append(eventID)
                    let userRef = self.db.collection(UserConstants.recordTypeKey).document(user.userID)
                    userRef.setData([UserConstants.pendingKey : user.pending], merge: true)
                    print("Added user \(user.userName) to event")
                }
            }
            return completion(true)
        }
    }
    
    /**
     Deletes user data from server and then deletes user auth from firestore
     
     ## Important Note ##
     - Function requires internet acess to work
     
     - Parameter user: A MUser record that you want to be deleted in the firestore database
     - Parameter completion: Runs at the completion of all tasks to help resolve conflicts with singletons.
     */
    func deleteUser(user: MUser, completion: @escaping (Bool) -> Void) {
        db.collection(UserConstants.recordTypeKey).document(user.userID).delete() { error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            } else {
                self.currentUser = nil
                guard let user = Auth.auth().currentUser else { return completion(false)}
                user.delete { error in
                    if let error = error {
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        return completion(false)
                    }
                    return completion(true)
                }
            }
        }
    }
}
