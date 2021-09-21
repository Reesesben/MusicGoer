//
//  ToDoTableViewCell.swift
//  Music Goer
//
//  Created by Ben Erekson on 9/15/21.
//

import UIKit


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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ToDoImage.isHidden = false
        ToDoText.text = ""
        ToDoButton.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    //MARK: - Helper Methods
    func updateViews() {
        guard let todo = todo else { return }
        ToDoButton.setTitle("", for: .normal)
        ToDoText.text = todo.title
        if todo.isComplete {
            ToDoButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            ToDoButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        if let image = todo.image {
            ToDoImage.image = image
        } else {
            ToDoImage.isHidden = true
        }
        
    }
    
    //MARK: - Actions
    @IBAction func ToDoButtonWasTapped(_ sender: Any) {
        if ToDoButton.image(for: .normal) == UIImage(systemName: "circle") {
            ToDoButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            todo?.isComplete = true
        } else {
            ToDoButton.setImage(UIImage(systemName: "circle"), for: .normal)
            todo?.isComplete = false
        }
    }
    
}
