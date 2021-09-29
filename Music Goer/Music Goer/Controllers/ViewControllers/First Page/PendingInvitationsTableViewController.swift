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
    var refresh: UIRefreshControl = UIRefreshControl()
    
    //MARK: - Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let currentUser = MUserController.shared.currentUser else { return }
        if currentUser.reports >= 30 {
            guard let lastReport = currentUser.lastReport else { return }
            let currentDate = Date()
            
            guard let timeInterval = Calendar.current.dateComponents([.day], from: lastReport, to: currentDate).day else { return }
            let daysLeft = 30 - timeInterval
            if daysLeft <= 0 {
                currentUser.reports = 0
                currentUser.lastReport = nil
                MUserController.shared.saveUser(user: currentUser) {
                    print("Reset User reports.")
                }
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "suspendedVC")
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }
        }
        if freshLaunch {
            freshLaunch = false
            tabBarController?.selectedIndex = 1
        } else {
            refetchData(completion: {
                self.tableView.reloadData()
            })
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
        updateViews()
        colorGradient()
        tableView.addSubview(refresh)
        refresh.addTarget(self, action: #selector(refetchData), for: .valueChanged)
    }
    
    @objc func refetchData(completion: @escaping () -> Void) {
        self.refresh.beginRefreshing()
        guard let current = Auth.auth().currentUser else { return }
        MUserController.shared.fetchUser(googleRef: current.uid) { _ in
            guard let current = MUserController.shared.currentUser else { return }
            print("\(current.pending.count) Pending Invitaitons")
            if current.pending.count != 0 {
                EventController.shared.fetchEvents(with: current.pending) { invites, sucess  in
                    if sucess {
                        guard let invites = invites else { return }
                        self.pending = []
                        self.pending.append(contentsOf: invites)
                        for event in self.pending {
                            if let inviter = event.members.first {
                            if current.blocked.contains(inviter) {
                                print("Event had blocked user")
                                guard let index = current.pending.firstIndex(of: event.eventID) else { return completion()}
                                current.pending.remove(at: index)
                                self.pending.remove(at: index)
                                MUserController.shared.saveUser(user: current) {
                                    print("Removed blocked invitation")
                                }
                            }
                            } else {
                                print("Event had no members")
                                guard let index = current.pending.firstIndex(of: event.eventID) else { return completion()}
                                current.pending.remove(at: index)
                                self.pending.remove(at: index)
                                MUserController.shared.saveUser(user: current) {
                                    print("Removed null invitation")
                                }
                            }
                        }
                        return completion()
                    } else {
                        return completion()
                    }
                }
            } else {
                return completion()
            }
        }
        self.refresh.endRefreshing()
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
        cell.addGradientBackground(firstColor: UIColor(#colorLiteral(red: 0.1294, green: 0.0196, blue: 0.2078, alpha: 1)), secondColor: UIColor(#colorLiteral(red: 0.2627, green: 0.051, blue: 0.2941, alpha: 1)), thirdColor: UIColor(#colorLiteral(red: 0.4824, green: 0.2, blue: 0.4902, alpha: 1)), fourthColor: UIColor(#colorLiteral(red: 0.7843, green: 0.4549, blue: 0.698, alpha: 1)), fifthColor: UIColor(#colorLiteral(red: 0.9608, green: 0.8353, blue: 0.8784, alpha: 1)))

        cell.layer.cornerRadius = 12
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.black.cgColor

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
            EventController.shared.events.append(event)

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
                EventController.shared.events.append(event)
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

        self.tableView.backgroundView?.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension PendingInvitationsTableViewController: invitationCellDelegate {
    func declineButtonTapped(indexPath: IndexPath) {
        let event = pending[indexPath.row]
        reject(event: event, completion: {
            
        })
    }
    
    func acceptButtonTapped(indexPath: IndexPath) {
        let event = pending[indexPath.row]
        accept(event: event, completion: {
            
        })
        
    }
}
