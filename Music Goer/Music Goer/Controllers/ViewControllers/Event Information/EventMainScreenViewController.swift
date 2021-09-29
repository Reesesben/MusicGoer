/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EventMainScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var chatHeadCollectionView: UICollectionView!
    @IBOutlet weak var toDoListTableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
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
    private let channelCellIdentifier = "channelCell"
    private var currentChannelAlertController: UIAlertController?
    
    private let database = Firestore.firestore()
    private var channelReference: CollectionReference {
        return database.collection(EventConstants.RecordTypeKey).document(event!.eventID).collection("channels")
    }
    
    var channels: [Channel] = []
    private var channelListener: ListenerRegistration?
    private var isFreshLaunch = true
    
    deinit {
        channelListener?.remove()
    }
    
    //MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let event = event,
        let admin = event.members.first,
        let currentUser = MUserController.shared.currentUser else { return }
        
        if admin != currentUser.userID {
            guard let index = self.navigationItem.rightBarButtonItems?.firstIndex(of: editButton) else { return }
            self.navigationItem.rightBarButtonItems?.remove(at: index)
        }
        
        channelListener = channelReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        loadViewIfNeeded()
        navigationController?.delegate = self
        chatHeadCollectionView.delegate = self
        chatHeadCollectionView.dataSource = self
        toDoListTableView.delegate = self
        toDoListTableView.dataSource = self
        updateViews()
        colorGradient()
        chatHeadCollectionView.reloadData()
    }
    
    //MARK: - ACTIONS
    
    @IBAction func driverButtonTapped(_ sender: Any) {
        
    }
    
    
    @objc private func addButtonPressed() {
        let alertController = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { field in
            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
            field.placeholder = "Channel name"
            field.returnKeyType = .done
            field.tintColor = .blue
        }
        
        let createAction = UIAlertAction(
            title: "Create",
            style: .default) { _ in
            self.createChannel()
        }
        createAction.isEnabled = false
        alertController.addAction(createAction)
        alertController.preferredAction = createAction
        
        present(alertController, animated: true) {
            alertController.textFields?.first?.becomeFirstResponder()
        }
        currentChannelAlertController = alertController
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let alertController = currentChannelAlertController else {
            return
        }
        alertController.preferredAction?.isEnabled = field.hasText
    }
    
    //MARK: - Helper funcs
    
    private func createChannel() {
        guard
            let alertController = currentChannelAlertController,
            let channelName = alertController.textFields?.first?.text
        else {
            return
        }
        
        let channel = Channel(name: channelName)
        channelReference.addDocument(data: channel.representation) { error in
            if let error = error {
                print("Error saving channel: \(error.localizedDescription)")
            }
        }
    }
    
    private func addChannelToTable(_ channel: Channel) {
        if channels.contains(channel) {
            return
        }
        channels.append(channel)
        channels.sort()
        
    }
    func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            addChannelToTable(channel)
        case .modified:
            return
        case .removed:
            return
        }
    }
    
    func getPhotos() {
        guard let event = event else { return }
        EventController.shared.getPhoto(userRefs: event.members, completion: { images in
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if channels.first != nil {
            guard let channel = channels.first else { return }
            let viewController = ChatViewController(user: currentUser, channel: channel, event: event)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            addButtonPressed()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatHeadCell", for: indexPath) as? UserChatHeadCollectionViewCell else {return UICollectionViewCell() }
        
        cell.backgroundColor = .clear
        cell.layer.borderWidth = 3
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
        cell.backgroundColor = .clear
        cell.addGradientBackground(firstColor: UIColor(#colorLiteral(red: 0.1137, green: 0.0667, blue: 0.2078, alpha: 1)), secondColor: UIColor(#colorLiteral(red: 0.0471, green: 0.0863, blue: 0.3098, alpha: 1)), thirdColor: UIColor(#colorLiteral(red: 0.3373, green: 0.2627, blue: 0.9922, alpha: 1)), fourthColor: UIColor(#colorLiteral(red: 0.4627, green: 0.2863, blue: 0.9961, alpha: 1)), fifthColor: UIColor(#colorLiteral(red: 0.9882, green: 0.9843, blue: 0.9961, alpha: 1)))
        cell.layer.cornerRadius = 24.5
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.black.cgColor
        
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
            
        } else if segue.identifier == "toLocationVC" {
            guard let destination = segue.destination as? LocationViewController,
                  let event = event else { return }
            destination.event = event
        } else if segue.identifier == "editEvent" {
            guard let destination = segue.destination as? CreateEventViewController,
                  let event = event else { return }
            destination.event = event
        }
    }
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.toDoListTableView.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.purple.cgColor]
        
        self.toDoListTableView.backgroundView = UIView.init(frame: self.view.bounds)
        
        self.toDoListTableView.backgroundView?.layer.insertSublayer(gradientLayer, at: 0)
        
        let gradientCollection = CAGradientLayer()
        
        gradientCollection.frame = self.chatHeadCollectionView.bounds
        
        gradientCollection.colors = [UIColor.systemRed.cgColor]
        
        self.chatHeadCollectionView.backgroundView = UIView.init(frame: self.view.bounds)
        
        self.chatHeadCollectionView.backgroundView?.layer.insertSublayer(gradientCollection, at: 0)
        
    }
}

extension EventMainScreenViewController: TodoDetailDelegate {
    func didUpdateToDo() {
        self.toDoListTableView.reloadData()
    }
}

extension EventMainScreenViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let title = viewController.title else { return }
        if title == "Events" {
            viewController.tabBarController?.tabBar.isHidden = false
        }
    }
}
