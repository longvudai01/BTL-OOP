//
//  TasksVC.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/17/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class TasksVC: UIViewController {
    
    // MARK: - Enum
    
    private enum Segue {
        static let addTaskVC = "AddTask"
    }
    @IBOutlet weak var popupView: PopupView!
    
    @IBOutlet weak var bottomPopupView: NSLayoutConstraint!
    @IBOutlet weak var heightPopupView: NSLayoutConstraint!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var messagelabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var addNewTaskLabel: UILabel!
    
    @IBOutlet weak var addTaskStackView: UIStackView!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var inputTF: UITextField!
    
    // MARK: - Properties
    
    
    
    var managedObjectContext: NSManagedObjectContext?

    private lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        let predicate = NSPredicate(format: "isFinished = 0")
      
        // Configure Fetch Request
        
  //      fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Task.updatedAt), ascending: false)
        ]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext!,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        
        return fetchedResultsController
    }()
    
    
    // MARK: -

    private var tags: [Tag]?
    
    private var hasTasks: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false}
        return fetchedObjects.count > 0
    }
    
    
    private lazy var updatedAtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        return dateFormatter
    }()
    
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchTasks()
        updateView()
        
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotification(notification:)),
                                               name: Notification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)

    }
    
    
    deinit {
        print("TasksVC Was Deinited")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavigationController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
             //   self.testView.isHidden = true
                self.keyboardHeightLayoutConstraint?.constant = 0
            } else {
             //   self.testView.isHidden = false
                self.keyboardHeightLayoutConstraint?.constant = (endFrame?.size.height)! - (tabBarController?.tabBar.frame.height)!
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}

        switch identifier {
        case Segue.addTaskVC:
            guard let destionation = segue.destination as? AddTaskVC else {return}

            // Configure Context
            destionation.managedObjectContext = managedObjectContext
            
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case Segue.addTaskVC:
            if let taskTitle = inputTF.text, !taskTitle.isEmpty {
                // Create Task
                let task = Task(context: managedObjectContext!)//coreDataManager.managedObjectContext)
                
                // Configure Task
                task.updatedAt = Date()
                task.createdAt = Date()
                task.title = taskTitle

                clearTextField(inputTF)
                dismissKeyboard()
                return false
            }
            else {
                return true
            }
        default:
            return false
        }
    }

    // MARK: - Methods
    private func setupView() {
        setupMessageLabel()
        setupTableView()
        view.backgroundColor = .white
        inputTF.delegate = self
        setupPopupView()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    fileprivate func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        title = "All Tasks"
    }
    
    private func updateView() {
        tableView.isHidden = !hasTasks
        messagelabel.isHidden = hasTasks
        addNewTaskLabel.isHidden = hasTasks
        emptyImageView.isHidden = hasTasks
    }
    
    private func setupMessageLabel() {
        messagelabel.text = "There's nothing here yet."
        addNewTaskLabel.text = "Add new task..."
    }
    
    private func setupPopupView() {
        
        popupView.backgroundColor = .clear
        popupView.isOpaque = false
        popupView.tableView.backgroundView = nil
        popupView.tableView.backgroundColor = .clear
        
        popupView.delegate = self
        
        heightPopupView.constant = 0
    }
    
    

    // MARK: - Helper Methods
    
    private func fetchTasks() {
        do {
            try self.fetchedResultsController.performFetch()
            
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    // MARK: - Actions
    @IBAction func sortWasPressed(_ sender: UIBarButtonItem) {
        configure()
        animateIn()
        addTaskStackView.isHidden = true
    }
    @IBAction func addTaskButtonWasPressed(_ sender: Any) {
    }
    
    @IBAction func detailsButtonWasPressed(_ sender: UIButton) {
        guard let detailsNavigationVC = storyboard?.instantiateViewController(withIdentifier: "DetailsNavigationVC") as? UINavigationController else { return }
    
        let detailsTableVC = detailsNavigationVC.topViewController as! DetailsTableVC
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        // fetch task
        let task = fetchedResultsController.object(at: indexPath)

        // Configure Destination
        detailsTableVC.task = task
        present(detailsNavigationVC, animated: true, completion: nil)
    }
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TasksVC: UITableViewDataSource, UITableViewDelegate {
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {return nil}
        var titleSection = sectionInfo.name
        if section == 0 {
            titleSection = "To Day"
        }
        return titleSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // return tasks.count
        guard let section = fetchedResultsController.sections?[section] else {return 0}
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TasksCell.reuseIdentifier, for: indexPath) as? TasksCell else {
            fatalError("Unexpected Index Path")
        }
        cell.selectionStyle = .none
        
        // Configure Cell
        configure(cell, at: indexPath)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func configure(_ cell: TasksCell, at indexPath: IndexPath) {
        
        // Fetch Task
        let task = fetchedResultsController.object(at: indexPath)
        
        // Configure Cell
        cell.delegate = self
        cell.setupSwipe()
        
        cell.taskTitleTextView.backgroundColor = .white
        cell.taskTitleTextView.delegate = self
        cell.taskTitleTextView.text = task.title
        
        cell.infoButton.isHidden = true

        tags = task.tag?.allObjects as? [Tag]
        
        if tags?.count == 0 {
            cell.heightTaskCellConstraint.priority = UILayoutPriority(rawValue: 999)
            cell.heightTaskTagExpanded.priority = UILayoutPriority(rawValue: 250)
        }
        else { cell.heightTaskCellConstraint.priority = UILayoutPriority(rawValue: 250)
            cell.heightTaskTagExpanded.priority = UILayoutPriority(rawValue: 999)
        }
        
        // Date and Frequency
        if task.hasAlarm {

            // Fetch Reminder matching with Task
            guard let reminder = TimedReminderStore.shared.fetchReminderWithCalendarItemIdentifier(with: task.calendarIdentifier!) as? EKReminder else {
                task.hasAlarm = !task.hasAlarm
                return
            }
        
            let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)

            // Fetch the date by which the reminder should be completed
            let date = gregorian.date(from: reminder.dueDateComponents!)
            let formattedDateString = HelperClass.dateFormatterShort.string(from: date!)
            var frequency: String = ""

            // If the reminder is a recurring one, only show its first recurrence rule
            if (reminder.hasRecurrenceRules) {
                // Fetch all recurrence rules associated with this reminder
                let recurrencesRules = reminder.recurrenceRules!
                let rule = recurrencesRules.first!
                frequency = rule.nameMatchingRecurrenceRuleWithFrequency( rule.frequency,
                                                                          interval: rule.interval)
            }
            
            // Use the hasRecurrenceRules property to determine whether to show the recurrence pattern for this reminder
            let dateAndFrequency = (reminder.hasRecurrenceRules) ? "\(formattedDateString), \(frequency)" : formattedDateString

            cell.dateAndLabelHeightConstraint.priority = UILayoutPriority(rawValue: 250)
            cell.dateAndFrequency.text = dateAndFrequency
        }
        else {
            cell.dateAndLabelHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        }
        
        
        
        cell.isFinished = task.isFinished
        if task.isFinished {
            cell.taskTitleTextView.isEditable = false
            cell.taskTitleTextView.isSelectable = false
        }
        else {
            cell.taskTitleTextView.isEditable = true
            cell.taskTitleTextView.isSelectable = true
        }

        cell.taskTagsView.backgroundColor = .white
        cell.taskTagsView.dataSource = self
        cell.taskTagsView.reload()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Task
        let task = fetchedResultsController.object(at: indexPath)
        
        // Delete Note
        managedObjectContext?.delete(task)
    }
}


extension TasksVC: TaskTagsViewDataSource {
    func numberOfViews(in taskTagsView: TaskTagsView) -> Int {
        if let tags = tags {
            return tags.count
        }
        else { return 0 }
    }
    
    func taskTagsView(_ taskTagsView: TaskTagsView, viewAt index: Int) -> UIView {
        guard let tags = tags else { return UIView() }
        let tag = tags[index]
        let tagView = TagViewInTask(frame: CGRect(x: 0, y: 0, width: 12, height: 12), tagColor: tag.colorName!)
        return tagView
    }
}

extension TasksVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard let indexPath = tableView.indexPath(for: textView) else { return false }
        let cell = tableView.cellForRow(at: indexPath) as! TasksCell
        
        cell.infoButton.isHidden = false
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        guard let indexPath = tableView.indexPath(for: textView) else { return false }
        let cell = tableView.cellForRow(at: indexPath) as! TasksCell
        
        cell.infoButton.isHidden = true
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        fixTextView(textView)
        tableView.endUpdates()
    }
}

extension TasksVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let taskTitle = textField.text, !taskTitle.isEmpty {
            // Create Task
            let task = Task(context: managedObjectContext!)
            
            // Configure Task
            task.updatedAt = Date()
            task.createdAt = Date()
            task.title = taskTitle
            
            
        }
        
        clearTextField(inputTF)
        dismissKeyboard()
        return true
    }
    
    private func clearTextField(_ textField: UITextField) {
        textField.text = ""
    }
}

extension TasksVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TasksCell {
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

extension TasksVC: TasksCellDelegate {
   
    func swipwRight(_ taskCell: TasksCell) {
        guard let indexPath = tableView.indexPath(for: taskCell) else { return }
        
        let task = fetchedResultsController.object(at: indexPath)
        task.isFinished = !task.isFinished
        
        task.hasAlarm = false
     //   task.calendarIdentifier = nil
    }
}


extension TasksVC: PopupViewDelegate {
    func sortByCategory() {
        
    }
    
    func configure() {
        self.updateViewConstraints()
    }
    
    func animateIn() {
        
        configure()
        popupView.alpha = 0.8
        
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.curveEaseIn],
                       animations: {
                        self.popupView.alpha = 1
                        self.heightPopupView.constant = 310
                        self.bottomPopupView.constant = 20
                        self.view.layoutIfNeeded()
        })
    }
    
    func animateOut () {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.popupView.alpha = 1
                        self.bottomPopupView.constant = -self.popupView.frame.height
                        self.view.layoutIfNeeded()
        })
        { (success: Bool) in
            print("remove")
        }
    }
    
    func dismissView() {
        animateOut()
        addTaskStackView.isHidden = false
    }
    
    func sortByGroceryList() {
       
    }
    
    func sortByDate() {
       
    }
}
