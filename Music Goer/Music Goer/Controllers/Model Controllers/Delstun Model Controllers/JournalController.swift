//
//  JournalController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import Foundation

class JournalController {
    
    //MARK: - Properties
    
    static let sharedInstance = JournalController()
    private init () {
        loadFroPersistenceStore()
    }
    
    //MARK: - This is your SOT
    var journals: [Journal] = []
    var date: [DateEntry] = []
    
    //MARK: - Functions
    func createJournal(title: String, name: String, date: Date) {
      
        let newJournal = Journal(title: title, name: name, date: date)
        
        journals.append(newJournal)
        saveToPersistenceStore()
    }
    
    func updateJournal(journal: Journal, title: String, date: Date) {
        journal.title = title
        journal.date = date
        saveToPersistenceStore()
        
    }
    
    func deleteJournal(journal: Journal) {
        
        guard let index = journals.firstIndex(of: journal) else { return }
        
        journals.remove(at: index)
    }
    
   //MARK: - Persistance
    func createPersistenceStore() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = url[0].appendingPathComponent("JournalEntry.json")
        return fileURL
    }

        
    
    func saveToPersistenceStore() {
        do {
            let data = try JSONEncoder().encode(journals)
            try data.write(to: createPersistenceStore())
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            
        }
    }
    
    func loadFroPersistenceStore() {
        do {
            
            let data = try Data(contentsOf: createPersistenceStore())
            journals = try JSONDecoder().decode([Journal].self, from: data)
        } catch {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        
    }
    static func updateJournal(journalEntry: String, journalBody: String) {
    
    
        }

}

    
