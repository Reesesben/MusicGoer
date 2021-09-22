//
//  EventDetailViewController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import UIKit

class EventDetailViewController: UIViewController {

    @IBOutlet weak var toDoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    var journal: Journal? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews(for: journal)

    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let titleName = toDoLabel.text, !titleName.isEmpty,
              let  nameLabel = nameLabel.text, !nameLabel.isEmpty else { return }
        
        if let journal = journal {
            JournalController.sharedInstance.updateJournal(journal: journal, title: titleName, date: eventDatePicker.date)
        } else {
            JournalController.sharedInstance.createJournal(title: titleName, name: nameLabel, date: eventDatePicker.date)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func updateViews(for journal: Journal?) {
        guard let journal = journal else { return }
        toDoLabel.text = journal.title
        nameLabel.text = journal.name
        eventDatePicker.date = journal.date ?? Date()
        
    }
    
    
    
    
    
    

}
