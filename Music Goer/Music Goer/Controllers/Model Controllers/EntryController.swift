//
//  EntryController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation

class EntryController {
 //shared instance
    

    //MARK: - SOT
    
    //MARK: - Create Entry
    static func createEntry(journalEntry: String, journalBody: String, journal: Journal) {
        let newEntry = Entry(journalEntry: journalEntry, journalBody: journalBody)
        journal.entries.append(newEntry)
        JournalController.sharedInstance.saveToPersistenceStore()
    }

    //MARK: - Delete Entry
    static func deleteEntry(entry: Entry, journal: Journal) {
        guard let index = journal.entries.firstIndex(of: entry) else { return }
        journal.entries.remove(at: index)
         
        JournalController.sharedInstance.saveToPersistenceStore()
    }
    
    static func updateEntry(entry: Entry, journalEntry: String, journalBody: String) {
        entry.journalEntry = journalEntry
        entry.journalBody = journalBody
    
        JournalController.sharedInstance.saveToPersistenceStore()
        }
    
}
