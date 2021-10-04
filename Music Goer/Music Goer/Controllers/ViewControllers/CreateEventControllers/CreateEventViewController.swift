//
//  CreateEventViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/24/œ21.
//

import UIKit

protocol createEventDelegate {
    func didCreateEvent()
}

class CreateEventViewController: UIViewController, UITextFieldDelegate {
    //MARK: - IBOutlets
    @IBOutlet var membersTableView: UITableView!
    @IBOutlet var ConcertTitleLabel: UITextField!
    @IBOutlet var concertDatePicker: UIDatePicker!
    @IBOutlet weak var backgroundImageForDate: UIImageView!
    @IBOutlet weak var addMemberButton: UIButton!
    
    //MARK: - Lifecycles
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        membersTableView.dataSource = self
        membersTableView.delegate = self
        if event != nil {
            updateViews()
        } else {
            guard let current = MUserController.shared.currentUser else { return }
            if members.count == 0 {
                members.insert(current, at: 0)
            }
        }
    }//End of func
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        ConcertTitleLabel.delegate = self
        addMemberButton.applyGradient(colors:[UIColor.orange.cgColor, UIColor.purple.cgColor])
        addMemberButton.layer.cornerRadius = addMemberButton.frame.height / 2
        addMemberButton.layer.borderColor = UIColor.purple.cgColor
        addMemberButton.layer.borderWidth = 3
        
        colorGradient()
        backgroundImageForDate.layer.cornerRadius = backgroundImageForDate.frame.height / 2
        
        self.hideKeyboardWhenTappedAround()
    }//End of func
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let gradientTableView = CAGradientLayer()
        
        gradientTableView.frame = self.membersTableView.bounds
        
        gradientTableView.colors = [UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor]
        
        self.membersTableView.backgroundView = UIView.init(frame: self.view.frame)
        
        self.membersTableView.backgroundView?.layer.insertSublayer(gradientTableView, at: 0)
    }//End of func
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 25
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }//End of func
    
    //MARK: - Properties
    var delegate: createEventDelegate?
    var members: [MUser] = []
    var event: Event?
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = ConcertTitleLabel.text else { return }
        
        var membersRefs: [String] = []
        for member in members {
            membersRefs.append(member.userID)
        }
        if let event = event {
            
            for member in membersRefs {
                if event.members.contains(member) {
                    guard let index = membersRefs.firstIndex(of: member) else { return }
                    membersRefs.remove(at: index)
                }
            }
            
            if !membersRefs.isEmpty {
                MUserController.shared.inviteUsers(memberRefs: membersRefs, eventID: event.eventID) { sucess in
                    if sucess {
                        event.title = title
                        event.date = self.concertDatePicker.date
                        
                        EventController.shared.updateEvent(event: event) {
                            self.navigationController?.popViewController(animated: true)
                            self.delegate?.didCreateEvent()
                        }
                    } else {
                        self.displayError(title: "Error saving event", Body: "An error occurred trying to save your event please check internet connection and try again.", completion: nil)
                    }
                }
            } else {
                event.title = title
                event.date = self.concertDatePicker.date
                
                EventController.shared.updateEvent(event: event) {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didCreateEvent()
                }
            }
            
            
        } else {
            EventController.shared.createEvent(title: title, date: concertDatePicker.date, members: membersRefs ) {sucsess in
                if sucsess {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didCreateEvent()
                } else {
                    self.displayError(title: "Error creating event!", Body: "An erorr occurred creating the event please make sure you are connected to Internet")
                }
                
            }
        }
    }
    //MARK: - Helper Methods
    func updateViews() {
        guard let event = event else { return }
        ConcertTitleLabel.text = event.title
        concertDatePicker.date = event.date
        backgroundImageForDate.layer.cornerRadius = backgroundImageForDate.frame.height / 2
        MUserController.shared.getUsers(userNames: event.members) { users, error in
            if error != nil {
                return
            }
            guard let users = users else { return }
            self.members = users
            UIView.animate(withDuration: 0.2) {
                self.membersTableView.reloadData()
            }
        }
        //BEREK do address
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userSearch" {
            guard let destination = segue.destination as? UserSearchViewController else { return }
            destination.delegate = self
        }
    }
}
extension CreateEventViewController: UserSearchDelegate {
    func didAddUser(user: MUser) {
        if !members.contains(user) {
            members.append(user)
            
        }
        membersTableView.reloadData()
    }
}

extension CreateEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? memberTableViewCell else { return UITableViewCell()}
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.addGradientBackground(firstColor: UIColor(#colorLiteral(red: 0.1137, green: 0.0667, blue: 0.2078, alpha: 1)), secondColor: UIColor(#colorLiteral(red: 0.0471, green: 0.0863, blue: 0.3098, alpha: 1)), thirdColor: UIColor(#colorLiteral(red: 0.3373, green: 0.2627, blue: 0.9922, alpha: 1)), fourthColor: UIColor(#colorLiteral(red: 0.4627, green: 0.2863, blue: 0.9961, alpha: 1)), fifthColor: UIColor(#colorLiteral(red: 0.9882, green: 0.9843, blue: 0.9961, alpha: 1)))
        cell.layer.cornerRadius = 12
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.black.cgColor
        cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2
        cell.updateCell(with: members[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            members.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
extension CreateEventViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let title = viewController.title else { return }
        if title == "Events" {
            viewController.tabBarController?.tabBar.isHidden = false
        }
    }
}

