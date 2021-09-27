//
//  UserSearchViewController.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/24/21.
//

import UIKit

protocol UserSearchDelegate {
    func didAddUser(user: MUser)
}

class UserSearchViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet var userSearchBar: UISearchBar!
    @IBOutlet var resultsTableView: UITableView!
    let popoverLabel = UILabel()
    
    //MARK: - Lifecycles
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        
        
        
        
        popoverLabel.backgroundColor = .systemGray
        popoverLabel.textColor = .label
        popoverLabel.alpha = 0.8
        
        popoverLabel.frame = CGRect (
            x: 12,
            y: (view.frame.size.height) - (view.frame.size.height * 0.05) - 24,
            width: (view.frame.size.width - 24),
            height: view.frame.size.height * 0.05
        )
        
        popoverLabel.layer.cornerRadius = popoverLabel.frame.height / 2
        popoverLabel.textAlignment = .center
        popoverLabel.layer.masksToBounds = true
        self.view.addSubview(popoverLabel)
        
        popoverLabel.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        userSearchBar.delegate = self
    }
    
    //MARK: - Helper Methods
    func presentPopupMessage(message: String) {
        popoverLabel.text = message
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.popoverLabel.isHidden = false
        } completion: { _ in
            UIView.animate(withDuration: 0.2, animations: {
                
            }, completion: { _ in
                DispatchQueue.global().async {
                    sleep(3)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut){
                            self.popoverLabel.isHidden = true
                        }
                    }
                }
            })
        }
    }
    
    //MARK: - Properties
    var delegate: UserSearchDelegate?
    var searchResults: [MUser] = [] {
        didSet {
            resultsTableView.reloadData()
        }
    }
}

//MARK: - TableView Methods
extension UserSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? SearchTableViewCell else { return UITableViewCell()}
            cell.updateCell(with: searchResults[indexPath.row])
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noResultsCell", for: indexPath)
            cell.textLabel?.text = "No results!"
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchResults.count != 0{
            delegate?.didAddUser(user: searchResults[indexPath.row])
            resultsTableView.deselectRow(at: indexPath, animated: true)
            userSearchBar.text = ""
            presentPopupMessage(message: "Sucessfully added \(searchResults[indexPath.row].userName) to event")
            self.searchResults = []
            self.resultsTableView.reloadData()
        }
    }
}

//MARK: - Search Bar Functions
extension UserSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        MUserController.shared.searchUser(userName: searchText) { newUsers, error in
            if error != nil {
                print("Error searching for users")
                return
            }
            
            guard let newUsers = newUsers else { return }
            self.searchResults = newUsers
        }
    }
}
