//
//  EventMainScreenViewController.swift
//  Music Goer
//
//  Created by Delstun McCray on 9/21/21.
//

import UIKit

class EventMainScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var chatHeadCollectionView: UICollectionView!
    @IBOutlet weak var toDoListTableView: UITableView!
    
    var character: [Character] = []
    var date: [DateEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
        updateViews()
        chatHeadCollectionView.delegate = self
        chatHeadCollectionView.dataSource = self
        toDoListTableView.delegate = self
        toDoListTableView.dataSource = self
        
    }
    
    func updateViews() {
        loadViewIfNeeded()
        chatHeadCollectionView.reloadData()
    }
    
    @IBAction func addToListButtonTapped(_ sender: Any) {
        addToAssignList()
        
    }
    
    //MARK: - CollectionView Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CharacterController.character.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatHeadCell", for: indexPath) as? UserChatHeadCollectionViewCell else {return UICollectionViewCell() }
        
        let character = CharacterController.character[indexPath.row]
        
        cell.character = character
        
        return cell
    }

    //MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JournalController.sharedInstance.journals.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let journal = JournalController.sharedInstance.journals[indexPath.row]
            JournalController.sharedInstance.deleteJournal(journal: journal)
            
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoListTableViewCell", for: indexPath)
        
        let journal = JournalController.sharedInstance.journals[indexPath.row]
        
        cell.textLabel?.text = journal.title
        cell.detailTextLabel?.text = journal.name
        
        return cell
    }
        
    func addToAssignList() {
        
        let alert = UIAlertController(title: "Create and assign.", message: "Add title", preferredStyle: .alert)
        
        alert.addTextField { toDoList in
            toDoList.placeholder = "Write To Do here...."
            
        }
        
        alert.addTextField { assigningTo in
            assigningTo.placeholder = "Who is in charge of this?"
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            
            guard let assignmentTitle = alert.textFields![0].text,
                  let nameLabel = alert.textFields![1].text else { return }
            
            JournalController.sharedInstance.createJournal(title: assignmentTitle, name: nameLabel, date: Date())
            self.toDoListTableView.reloadData()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true)
        
    }
}
