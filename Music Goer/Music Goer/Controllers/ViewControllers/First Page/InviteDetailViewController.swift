//
//  InviteDetailViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/27/21.
//

import UIKit

protocol inviteDetailDelegate {
    func reject(event: Event, completion: @escaping () -> Void)
    func accept(event: Event, completion: @escaping () -> Void)
}

class InviteDetailViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var inviteLabel: UILabel!
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        updateViews()
        overrideUserInterfaceStyle = .light
    }
    //MARK: - Properties
    var event: Event?
    var creator: MUser?
    var delegate: inviteDetailDelegate?
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let event = event,
        let host = event.members.first else { return }
        MUserController.shared.getUsers(userNames: [host]) { results, error in
            if error != nil {print("Error retrieving user Information")}
            guard let results = results,
            let user = results.first else { return }
            self.creator = user
            self.userImageView.image = UIImage(data: user.userImage)
            self.inviteLabel.text = "\(user.userName) would like to invite you to \(event.title)"
        }
    }
    
    //MARK: - Actions
    @IBAction func rejectButtonTapped(_ sender: Any) {
        guard let event = event,
        let delegate = delegate else { return }
        delegate.reject(event: event, completion: {
            self.dismiss(animated: true)
        })
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let event = event,
              let delegate = delegate else { return }
        delegate.accept(event: event, completion: {
            self.dismiss(animated: true)
        })
    }
    
    @IBAction func moreOptionsButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "More Acitons", message: nil, preferredStyle: .actionSheet)
        let blockUser = UIAlertAction(title: "Block", style: .destructive) { _ in
            guard let current = MUserController.shared.currentUser,
                  let creator = self.creator else { return }
            current.blocked.append(creator.userID)
            MUserController.shared.saveUser(user: current) {
                self.dismiss(animated: true, completion: nil)
                guard let event = self.event,
                      let delegate = self.delegate else { return }
                delegate.reject(event: event, completion: {
                    self.dismiss(animated: true)
                })
            }
        }
        let reportUser = UIAlertAction(title: "Report", style: .destructive) { _ in
            guard let creator = self.creator else { return }
            creator.reports += 1
            creator.lastReport = Date()
            MUserController.shared.saveUser(user: creator) {
                self.dismiss(animated: true, completion: nil)
                guard let event = self.event,
                      let delegate = self.delegate else { return }
                delegate.reject(event: event, completion: {
                    self.dismiss(animated: true)
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(blockUser)
        alert.addAction(reportUser)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
}
