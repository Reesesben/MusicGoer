//
//  PendingInvitationsTableViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit
import FirebaseAuth

class PendingInvitationsTableViewController: UITableViewController {
    
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        guard let current = MUserController.shared.currentUser else { return }
        pending.remove(at: indexPath.row)
        current.pending.remove(at: indexPath.row)
        MUserController.shared.saveUser(user: current) {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func acceptButtonTapped(indexPath: IndexPath) {
        guard let current = MUserController.shared.currentUser else { return }
        let event = pending[indexPath.row]
        event.members.append(current.userID)
        current.pending.remove(at: indexPath.row)
        pending.remove(at: indexPath.row)
        EventController.shared.updateEvent(event: event) {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        MUserController.shared.saveUser(user: current) {
            print("User Was saved")
        }
    }
}
