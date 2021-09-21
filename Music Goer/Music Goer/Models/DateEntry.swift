//
//  DateEntry.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation

class DateEntry: Codable {
    
    let journalDate: Date
    
    let uuid: String
    
    init(journalDate: Date = Date(), uuid: String = UUID().uuidString ) {
        self.journalDate = journalDate
        self.uuid = uuid
    }
    
}//End of class

//MARK: - Extensions
extension DateEntry: Equatable {
    static func == (lhs: DateEntry, rhs: DateEntry) -> Bool{
        return lhs.uuid == rhs.uuid

    }
}


