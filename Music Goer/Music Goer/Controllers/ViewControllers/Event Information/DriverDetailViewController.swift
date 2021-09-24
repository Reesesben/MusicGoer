//
//  DriverDetailViewController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 9/20/21.
//

import UIKit

class DriverDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var mapsButton: UIButton!
    
    
    //MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        colorGradient()
        updateViews()

    }
    
    //MARK: - Actions
    @IBAction func driverButtonTapped(_ sender: Any) {
        driverAlertController()
        
    }
    
    @IBAction func mapsButtonTapped(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "MapsViewController")
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true, completion: nil)
//        driverAlertController()
    }
    
    
    
    //MARK: - Helper funcs
    func updateViews() {
        loadViewIfNeeded()
        driverLabel.text = driverLabel.text
        
    }
    
    func colorGradient() {
        
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.yellow]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func driverAlertController() {
        
        let alert = UIAlertController(title: "Whos driving?", message: "Whats there name?", preferredStyle: .alert)
        
        alert.addTextField { driverList in
            driverList.placeholder = "Add driver here...."
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [self] _ in
            
            guard let driverTitle = alert.textFields![0].text else { return }
            
            _ = driverLabel.text
            
            self.driverLabel.text = driverTitle
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true)
        
    }
    
}
