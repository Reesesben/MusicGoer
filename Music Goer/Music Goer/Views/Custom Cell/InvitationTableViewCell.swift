//
//  InvitationTableViewCell.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/25/21.
//

import UIKit

protocol invitationCellDelegate {
    func declineButtonTapped(indexPath: IndexPath)
    func acceptButtonTapped(indexPath: IndexPath)
}

class InvitationTableViewCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var adminNameLabel: UILabel!
    
    //MARK: - Properties
    var delegate: invitationCellDelegate?
    var indexPath: IndexPath?
    
    //MARK: - Cell Funcitons
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - Actions
    @IBAction func declineButtonTapped(_ sender: Any) {
        guard let delegate = delegate,
        let indexPath = indexPath else { return }
        delegate.declineButtonTapped(indexPath: indexPath)
    }
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let delegate = delegate,
        let indexPath = indexPath else { return }
        delegate.acceptButtonTapped(indexPath: indexPath)
    }
    
    //MARK: - Helper Methods
    /**
     Updates results cell with event information
             
        - Parameter event: event to populte the cell with.
     */
    func updateCell(_ event: Event) {
        eventNameLabel.text = event.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        adminNameLabel.text = "\(dateFormatter.string(from: event.date))"
    }

}
