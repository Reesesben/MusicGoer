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

class TodoDetailViewController: UIViewController, UITextFieldDelegate {
    
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
        todoTitleTextField.delegate = self
        personTextField.delegate = self
        overrideUserInterfaceStyle = .light
        dueDatePicker.layer.backgroundColor = CGColor.init(red: 1, green: 1, blue: 1, alpha: 0.50)
        dueDatePicker.alpha = 1
        
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
        
    }//End of func
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.purple.cgColor]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }//End of func
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }//End of func
}//End of class
