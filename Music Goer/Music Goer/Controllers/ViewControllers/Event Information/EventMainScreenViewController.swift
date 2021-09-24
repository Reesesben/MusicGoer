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
    var members: [UIImage] = [] {
        didSet {
            chatHeadCollectionView?.reloadData()
        }
    }
    var event: Event? {
        didSet {
           getPhotos()
        }
    }
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
    
    func getPhotos() {
        guard let event = event else { return }
        EventController.shared.getPhoto(userRefs: event.members, completion: { images in
            print(images.count)
                self.members = images
        })
    }
    
    func updateViews() {
        loadViewIfNeeded()
        chatHeadCollectionView.reloadData()
        guard let event = event else { return }
        EventController.shared.fetchTodos(for: event, completion: {
            self.toDoListTableView.reloadData()
        })

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
        return members.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatHeadCell", for: indexPath) as? UserChatHeadCollectionViewCell else {return UICollectionViewCell() }
        
        cell.member = members[indexPath.row]
        
        return cell
    }
    
    //MARK: - TableView things
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let event = event else { return 0}
        return event.todos.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let event = event else { return }
            let todo = event.todos[indexPath.row]
            EventController.shared.deleteToDo(event: event, todo: todo, completion: { _ in
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoListTableViewCell", for: indexPath)
        
        guard let event = event else { return UITableViewCell()}
        
        cell.textLabel?.text = event.todos[indexPath.row].title
        cell.detailTextLabel?.text = event.todos[indexPath.row].person
        
        return cell
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toListDetailVC" {
            guard let index = toDoListTableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? TodoDetailViewController,
                  let event = event else { return }
            destinationVC.event = event
            destinationVC.delegate = self
            destinationVC.todo = event.todos[index.row]
            
        } else if segue.identifier == "newTodo" {
            guard let destinationVC = segue.destination as? TodoDetailViewController,
                  let event = event else { return }
            destinationVC.event = event
            destinationVC.delegate = self
        }
    }
}

extension EventMainScreenViewController: TodoDetailDelegate {
    func didUpdateToDo() {
        self.toDoListTableView.reloadData()
    }
}
