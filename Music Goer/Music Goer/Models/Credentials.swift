//
//  Credentials.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/22/21.
//

import Foundation

struct CredentialsConstants {
    static let emailTypeKey = "Email"
    static let googleTypeKey = "Google"
    static let appleTypeKey = "Apple"
}
///Holds email, password, and type for user login.
class Credentials: Codable {
    var email: String?
    var password: String?
    var type: String
    
    init(email: String?, password: String?, type: String) {
        self.email = email
        self.password = password
        self.type = type
    }
}
