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
        overrideUserInterfaceStyle = .light
        tabBarController?.tabBar.isHidden = false
        updateViews()
        colorGradient()
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
        
        //let color = #colorLiteral
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.tableView.bounds
         
        gradientLayer.colors = [UIColor.black.cgColor,UIColor.black.cgColor, UIColor.purple.cgColor ,UIColor.purple.cgColor]
        
        self.tableView.backgroundView = UIView.init(frame: self.tableView.bounds)
        
        self.tableView.backgroundView?.layer.insertSublayer(gradientLayer, at: 0)
    
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
        cell.textLabel?.textColor = .white
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        cell.addGradientBackground(firstColor: UIColor(#colorLiteral(red: 0.1137, green: 0.0667, blue: 0.2078, alpha: 1)), secondColor: UIColor(#colorLiteral(red: 0.0471, green: 0.0863, blue: 0.3098, alpha: 1)), thirdColor: UIColor(#colorLiteral(red: 0.3373, green: 0.2627, blue: 0.9922, alpha: 1)), fourthColor: UIColor(#colorLiteral(red: 0.4627, green: 0.2863, blue: 0.9961, alpha: 1)), fifthColor: UIColor(#colorLiteral(red: 0.9882, green: 0.9843, blue: 0.9961, alpha: 1)))
        cell.layer.cornerRadius = 8.5
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.black.cgColor
                                                 
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
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
            navigationController?.delegate = destination
        } else if segue.identifier == "createEvent" {
            tabBarController?.tabBar.isHidden = true
            guard let destination = segue.destination as? CreateEventViewController else { return }
            destination.delegate = self
            navigationController?.delegate = destination
        }
    }
}
extension EventsTableViewController: createEventDelegate {
    func didCreateEvent() {
        self.tableView.reloadData()
    }
}

extension UIView{
    func addGradientBackground(firstColor: UIColor, secondColor: UIColor, thirdColor: UIColor, fourthColor: UIColor, fifthColor: UIColor){
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor, thirdColor.cgColor, fourthColor.cgColor, fifthColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
