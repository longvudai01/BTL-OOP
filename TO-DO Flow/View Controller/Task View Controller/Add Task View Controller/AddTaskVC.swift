//
//  AddTaskVC.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/21/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit
import CoreData

class AddTaskVC: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var inputTF: UITextField!
    @IBOutlet weak var addNoteTF: UITextField!
    
    // MARK: - Properties
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View life cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // show keyboard
        inputTF.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        print("AddTaskVC was deinited")
    }

    // MARK: - Actions
    
    @IBAction func saveButtonWasPressed(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else {return}
        guard let title = inputTF.text, !title.isEmpty else {
            showAlert(with: "Title Missing", and: "Your note doesn't have a title.")
            return
        }
        
        // Create Task
        let task = Task(context: managedObjectContext)
        
        // Configure Task
        task.updatedAt = Date()
        task.createdAt = Date()
        task.title = title
        task.content = addNoteTF.text ?? ""
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButtonWasPessed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
