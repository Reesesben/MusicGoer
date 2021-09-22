//
//  User.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/21/21.
//

import Foundation
import Firebase
import FirebaseAuth

struct UserConstants {
    static let recordTypeKey = "User"
    static let userIDKey = "UserID"
    static let userNameKey = "UserName"
    static let googleRefKey = "GoogleRef"
    static let acceptedKey = "AcceptedInvitations"
    static let pendingKey = "PendingInvitations"
    static let reportsKey = "UserReports"
    static let lastReportKey = "LastReportDate"
    static let imageDataKey = "ImageData"
}
/**
 User object attached to each user in FireStore
 
 ## Important Note ##
 - User must be registered in Database as a user
 
 - Parameter userID: ID for each unique user, also the record name in the Database
 - Parameter userName: Display name that other users search for user by
 - Parameter userImage: Data for the profile picture for each user
 - Parameter googleRef: Reference for Firebase User Auth Record in database
 - Parameter accepted: Array of event ids that the user is a part of
 - Parameter pending: Array of event ids the user has been added to and hasn't accepted
 - Parameter reports: Number representing the number of people who have reported the user.
 - Parameter lastReport: The date of the last time the user was reported.
 */
class MUser {
    let userID: String
    let userName: String
    let userImage: Data
    let googleRef: String
    let accepted: [String]
    let pending: [String]
    let reports: Int
    let lastReport: Date?
    
    init(userID: String = UUID().uuidString, userName: String, userImageData: Data, googleRef: String, accepted: [String] = [], pending: [String] = [], reports: Int = 0, lastReport: Date?) {
        self.userID = userID
        self.userName = userName
        self.userImage = userImageData
        self.googleRef = googleRef
        self.accepted = accepted
        self.pending = pending
        self.reports = reports
        self.lastReport = lastReport
    }
}
