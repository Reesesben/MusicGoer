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
        tabBarController?.tabBar.isHidden = false
        tableView.addSubview(refresh)
        print("Attempting to fetch events")
        EventController.shared.fetchEvents { sucess in
            if sucess {
                print("Sucessfully retrieved Events")
                if EventController.shared.events.count == 0 {
                    EventController.shared.createEvent(title: "Test Event", address: "New York City", date: Date(), members: ["ACDC9B5F-EB75-4B65-AC12-C83C10EA0998", "5F902D19-BD15-4F26-8663-5670BF3D2DD6"], completion: {
                        self.tableView.reloadData()
                    })
                } else {
                    self.tableView.reloadData()
                    print("Number of TODOS \(EventController.shared.events[0].todos.count)")
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
        }
    }
    
    
}
