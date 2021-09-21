//
//  Entry.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation

class Entry: Codable {
    
  var journalEntry: String
    
    var journalBody: String
    
    let journalDate: Date
    
    let uuid: String
    
    
    init(journalEntry: String, journalBody: String, journalDate: Date = Date(), uuid: String = UUID().uuidString) {
        self.journalEntry = journalEntry
        self.journalBody = journalBody
        self.journalDate = journalDate
        self.uuid = uuid
    }
    
    
}//End of Class

//MARK: - Extensions
extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool{
        return lhs.uuid == rhs.uuid

    }
}
