//
//  TodoViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/16/21.
//

import UIKit

class TodoViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
//        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        button.backgroundColor = .systemBlue
        button.setTitle("", for: .normal)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(floatingButton)
        eventIndex = EventController.shared.currentEventIndex
        event = EventController.shared.events[eventIndex]
        EventController.shared.createToDo(image: nil, title: "Test ToDo", category: "Test", address: "no", date: Date(), members: ["Test"])
        let add: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTodo))
        navigationController?.navigationItem.rightBarButtonItem = add
                
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let tbc = self.tabBarController else { return }
              let TBHeight = tbc.tabBar.frame.height
        floatingButton.frame = CGRect(x: view.frame.size.width - 92, y: view.frame.size.height - TBHeight * 2, width: 60, height: 60)
    }
    
    //MARK: - Properties
    var event: Event?
    var eventIndex: Int = 0
    
    //MARK: - Helper Methods
    @objc func addTodo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "todoEditor")
        vc.modalPresentationStyle = .popover
        present(vc, animated: true, completion: nil)
    }

}

extension TodoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventController.shared.events[eventIndex].todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath) as? ToDoTableViewCell else { return UITableViewCell()}
        guard let event = event else { return UITableViewCell()}
        cell.todo = event.todos[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}
