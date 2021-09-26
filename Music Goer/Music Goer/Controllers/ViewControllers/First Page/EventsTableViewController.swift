//
//  EventsTableViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit
import CoreLocation

class EventsTableViewController: UITableViewController {
    
    //MARK: - Lifecycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Events"
        setupViews()
        tabBarController?.tabBar.isHidden = false
        updateViews()
    }
    
    @objc func updateViews() {
        EventController.shared.fetchEvents { success in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            }
        }
    }
    
    func setupViews() {
        tableView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(updateViews), for: .valueChanged)
    }
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    var refresh: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return EventController.shared.events.count
    }
    
    override func viewDidLayoutSubviews() {
//        
//        let gradientLayer = CAGradientLayer()
//        
//        gradientLayer.frame = self.view.bounds
//        
//        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow]
//        
//        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        cell.textLabel?.text = EventController.shared.events[indexPath.row].title
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = EventController.shared.events[indexPath.row]
            EventController.shared.leaveEvent(event: event, completion: {
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetail" {
            tabBarController?.tabBar.isHidden = true
            guard let index = tableView.indexPathForSelectedRow,
                  let destination = segue.destination as? EventMainScreenViewController else { return }
            destination.event = EventController.shared.events[index.row]
        } else if segue.identifier == "createEvent" {
            tabBarController?.tabBar.isHidden = true
            guard let destination = segue.destination as? CreateEventViewController else { return }
            destination.delegate = self
        }
    }
}
extension EventsTableViewController: createEventDelegate {
    func didCreateEvent() {
        self.tableView.reloadData()
    }
}
