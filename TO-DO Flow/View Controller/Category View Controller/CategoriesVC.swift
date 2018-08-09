//
//  CategoriesVC.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/25/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit
import CoreData

class CategoriesVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: -

    var task: Task?
    
    // MARK: -
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        guard let managedObjectContext = self.task?.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: -
    
    lazy private var hasCategories: Bool = {
        var hasCategories = false
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            hasCategories = fetchedObjects.count > 0
        }
        return hasCategories
    }()
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchCategories()
    }
    
    // MARK: - Methods
    
    private func setupView() {
        title = "Categories"
        setupTableView()
    }

    
    private func fetchCategories() {
        do {
            try self.fetchedResultsController.performFetch()
            
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
}

extension CategoriesVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
      //  updateView()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
    
}

extension CategoriesVC: UITableViewDataSource {
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        return section.numberOfObjects + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Dequeue Reusable Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            fatalError("Unexpected Index Path")
        }
        
        cell.categoryNameTexField.delegate = self
        // Configure Cell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    
    
    func configure(_ cell: CategoryCell, at indexPath: IndexPath) {
        let endIdx = fetchedResultsController.sections?[indexPath.section].numberOfObjects
        
        cell.folderButton.backgroundColor = .clear
        if endIdx == indexPath.row {
            cell.categoryNameTexField.placeholder = hasCategories ? "New Category" :
            """
            You don't have any categories.
            Tap to add new Category
            """
            
            cell.folderButton.setImage(#imageLiteral(resourceName: "addItem"), for: .normal)
            
            cell.categoryNameLabel.isHidden = true
        }
            
        else {
            // Fetch Note
            let category = fetchedResultsController.object(at: indexPath)
            
            // Configure Cell
            cell.categoryNameLabel.text = category.name

            if task?.category == category {
                cell.folderButton.setImage(#imageLiteral(resourceName: "folder-color"), for: .normal)
            } else {
                cell.folderButton.setImage(#imageLiteral(resourceName: "folder"), for: .normal)
            }
            cell.categoryNameTexField.isHidden = true
        }
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Category
        let category = fetchedResultsController.object(at: indexPath)
        
        // Delete Category
        task?.managedObjectContext?.delete(category)
    }
    
    
    
}

extension CategoriesVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Fetch Category
        let category = fetchedResultsController.object(at: indexPath)
        
        // Update Note
        task?.category = category
        
        // Pop View Controller From Navigation Stack
        let _ = navigationController?.popViewController(animated: true)
    }
    
}

extension CategoriesVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        save(textField)
        return true
    }
    
    fileprivate func clearTextField(_ textField: UITextField) {
        textField.text = ""
    }
    
    private func save(_ textField: UITextField) {
        guard let managedObjectContext = task?.managedObjectContext else { return }
        guard let categoryName = textField.text, !categoryName.isEmpty else {
            showAlert(with: "Name Missing", and: "Your category doesn't have a name.")
            return
        }
        
        // Create Category
        let category = Category(context: managedObjectContext)
        
        // Configure Category
        category.name = textField.text
        
        clearTextField(textField)
    }
}
