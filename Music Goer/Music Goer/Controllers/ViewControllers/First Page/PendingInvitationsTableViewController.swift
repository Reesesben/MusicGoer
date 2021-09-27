//
//  PendingInvitationsTableViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit
import FirebaseAuth

class PendingInvitationsTableViewController: UITableViewController, inviteDetailDelegate {
    
    //MARK: - Properties
    var freshLaunch = true
    var pending: [Event] = []
    
    //MARK: - Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if freshLaunch {
            freshLaunch = false
            tabBarController?.selectedIndex = 1
        } else {
            guard let current = Auth.auth().currentUser else { return }
            MUserController.shared.fetchUser(googleRef: current.uid) { _ in
                guard let current = MUserController.shared.currentUser else { return }
                if current.pending.count != 0{
                    EventController.shared.fetchEvents(with: current.pending) { invites, sucess  in
                        if sucess {
                            guard let invites = invites else { return }
                            self.pending = []
                            self.pending.append(contentsOf: invites)
                            print("Number of pending \(self.pending.count)")
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
        updateViews()
       // colorGradient()
    }
    
    func updateViews() {
        loadViewIfNeeded()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pending.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath) as? InvitationTableViewCell else { return UITableViewCell()}
        
        cell.selectionStyle = .none
        cell.indexPath = indexPath
        cell.updateCell(pending[indexPath.row])
        cell.delegate = self
        cell.backgroundColor = .clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    //MARK: - Helper Methods
    func reject(event: Event, completion: @escaping () -> Void) {
        guard let current = MUserController.shared.currentUser,
        let index = pending.firstIndex(of: event) else { return }
        pending.remove(at: index)
        current.pending.remove(at: index)
        MUserController.shared.saveUser(user: current) {
            self.tableView.reloadData()
            return completion()
        }
    }
    
    func accept(event: Event, completion: @escaping () -> Void) {
        guard let current = MUserController.shared.currentUser,
        let index = pending.firstIndex(of: event) else { return }
        event.members.append(current.userID)
        current.pending.remove(at: index)
        pending.remove(at: index)
        EventController.shared.updateEvent(event: event) {
            MUserController.shared.saveUser(user: current) {
                self.tableView.reloadData()
                return completion()
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toInviteDetailScreen" {
            guard let destination = segue.destination as? InviteDetailViewController,
                  let indexPath = tableView.indexPathForSelectedRow else { return }
            destination.event = pending[indexPath.row]
            destination.delegate = self
        }
    }
    
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.tableView.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor]
        
        self.tableView.backgroundView = UIView.init(frame: self.tableView.bounds)
        
        self.tableView.backgroundView?.layer.insertSublayer(gradientLayer, at: 0)
        
        self.tableView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension PendingInvitationsTableViewController: invitationCellDelegate {
    func declineButtonTapped(indexPath: IndexPath) {
        let event = pending[indexPath.row]
        reject(event: event, completion: {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
    }
    
    func acceptButtonTapped(indexPath: IndexPath) {
        let event = pending[indexPath.row]
        accept(event: event, completion: {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
    }
}
