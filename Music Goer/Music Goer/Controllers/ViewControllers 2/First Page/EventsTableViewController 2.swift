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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
        if EventController.shared.events.count == 0 {
            EventController.shared.createEvent(title: "Test Event (EventsTableViewController)", address: CLLocationCoordinate2D(latitude: 1.0, longitude: 10.0), date: Date(), members: ["Test"])
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return EventController.shared.events.count
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
            EventController.shared.deleteEvent(event: event)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let event = EventController.shared.events[fromIndexPath.row]
        EventController.shared.moveEvent(event: event, newIndex: to.row)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEventDetail" {
            tabBarController?.tabBar.isHidden = true
            guard let index = tableView.indexPathForSelectedRow else { return }
            EventController.shared.currentEventIndex = index.row
        }
    }
    
    
}
