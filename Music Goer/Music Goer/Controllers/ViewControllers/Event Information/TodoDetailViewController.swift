//
//  EventDetailViewController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/17/21.
//

import UIKit

protocol TodoDetailDelegate {
    func didUpdateToDo()
}

class TodoDetailViewController: UIViewController {
    
    @IBOutlet var todoTitleTextField: UITextField!
    @IBOutlet var personTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    var event: Event?
    var todo: ToDo?
    var delegate: TodoDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorGradient()
        updateViews()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let dueDate = dueDatePicker.date
        guard let person = personTextField.text,
              let title = todoTitleTextField.text else { return }
        
        if title.isEmpty {
            displayError(title: "Todo must have a title", Body: "Todo must have a title to be updated!")
        } else if person.isEmpty {
            displayError(title: "A person needs to be assigned to this task", Body: "You need to assign a person to this task!")
        } else {
            guard let event = event else { return }
            if todo == nil {
                EventController.shared.createToDo(title: title, person: person, date: dueDate, event: event, completion: {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didUpdateToDo()
                })
            } else {
                guard let todo = todo else { return }
                todo.dueDate = dueDate
                todo.person = person
                todo.title = title
                EventController.shared.updateEvent(event: event, completion: {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didUpdateToDo()
                })
            }
        }
    }
    
    func updateViews() {
        guard let todo = todo else { return }
        todoTitleTextField.text = todo.title
        personTextField.text = todo.person
        dueDatePicker.date = todo.dueDate
        
    }
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    
    
    
    
}
