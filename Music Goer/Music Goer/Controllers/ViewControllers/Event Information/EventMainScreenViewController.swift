//
//  EventMainScreenViewController.swift
//  Music Goer
//
//  Created by Delstun McCray on 9/21/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EventMainScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var chatHeadCollectionView: UICollectionView!
    @IBOutlet weak var toDoListTableView: UITableView!
    
    //MARK: - Properties
    var characters: [fakeUser] = []
    var date: [DateEntry] = []
    private let currentUser: User = Auth.auth().currentUser!

    
    //MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
        updateViews()
        chatHeadCollectionView.delegate = self
        chatHeadCollectionView.dataSource = self
        toDoListTableView.delegate = self
        toDoListTableView.dataSource = self
        chatHeadCollectionView.reloadData()
        
    }
    
    //MARK: - Helper funcs
    
    func updateViews() {
        loadViewIfNeeded()
        chatHeadCollectionView.reloadData()
        
    }
    
    //MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addToAssignList()
    }
    
    
    // MARK: UICollectionViewDataSource
    
//    let channel = channels[indexPath.row]
//    let viewController = ChatViewController(user: currentUser, channel: channel)
//    navigationController?.pushViewController(viewController, animated: true)
//  }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ChannelsViewController(currentUser: currentUser)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(CharacterController.character.count)
        return CharacterController.character.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatHeadCell", for: indexPath) as? UserChatHeadCollectionViewCell else {return UICollectionViewCell() }
        
        let character = CharacterController.character[indexPath.row]
        
        cell.character = character
        cell.displayImageFor()
        
        return cell
    }
    
    //MARK: - TableView things
    
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
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toListDetailVC" {
                guard let index = toDoListTableView.indexPathForSelectedRow,
                      let destinationVC = segue.destination as?
                        EventDetailViewController else { return }
                let event = JournalController.sharedInstance.journals[index.row]
                destinationVC.journal = event
    
            }
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
