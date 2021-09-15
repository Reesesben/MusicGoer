//
//  ToDoTableViewCell.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit

protocol ToDoCellDelegate {
    func stateWasChanged(newState: Bool)
}

class ToDoTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet var ToDoImage: UIImageView!
    @IBOutlet var ToDoText: UILabel!
    @IBOutlet var ToDoButton: UIButton!
    
    //MARK: - Properties
    var todo: ToDo? {
        didSet{
            updateViews()
        }
    }
    
    //MARK: - Cell Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let todo = todo else { return }
        ToDoImage.image = todo.image
        ToDoText.text = todo.title
        if todo.isComplete {
            ToDoButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            ToDoButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        
    }
    
    //MARK: - Actions
    @IBAction func ToDoButtonWasTapped(_ sender: Any) {
        
    }
    

}
