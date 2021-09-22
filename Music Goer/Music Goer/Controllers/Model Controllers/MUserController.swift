//
//  UserController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/21/21.
//

import Foundation
import Firebase
import FirebaseAuth

class MUserController {
    /// Singleton for usercontroller to keep data consistent
    static var shared = MUserController()
    ///Current user logged into the database
    var currentUser: MUser?
    ///Reference to the main firestore where the app reads and writes data
    let db = Firestore.firestore()
    
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
    func createUser(userName: String, userImage: Data, googleRef: String, completion: @escaping () -> Void) {
        //BEREK Get google ref
        currentUser = MUser(userName: userName, userImageData: userImage, googleRef: googleRef, lastReport: nil)
        guard let currentUser = currentUser else {return}
        saveUser(user: currentUser, completion: {
            print("User Created Sucessfully")
            return completion()
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
                         UserConstants.acceptedKey : user.accepted,
                         UserConstants.pendingKey : user.pending,
                         UserConstants.reportsKey : user.reports,], merge: true)
        
        if let lastReport = user.lastReport {
            userRef.setData([UserConstants.lastReportKey : lastReport], merge: true)
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
                      let accepted = userData[UserConstants.acceptedKey] as? [String],
                      let pending = userData[UserConstants.pendingKey] as? [String],
                      let reports = userData[UserConstants.reportsKey] as? Int else { return completion(false)}
                
                let lastReport = userData[UserConstants.lastReportKey] as? Date ?? nil
                
                self.currentUser = MUser(userID: userID, userName: userName, userImageData: imageData, googleRef: googleRef, accepted: accepted, pending: pending, reports: reports, lastReport: lastReport)
                return completion(true)
            } else { return completion(false) }
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
                guard let user = Auth.auth().currentUser else { return }
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
