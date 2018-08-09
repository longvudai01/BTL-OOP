//
//  DetailsTableVC.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/25/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import EventKitUI


class DetailsTableVC: UITableViewController {
    
    private let ReminderTitleID = "ReminderTitleID"
    private let ReminderRemindMeOnDateID = "ReminderRemindMeOnDateID"
    private let ReminderAlarmID = "ReminderAlarmID"
    private let ReminderDatePickerID = "ReminderDatePickerID"
    private let ReminderFrequencyID = "ReminderFrequecyID"
    private let ReminderLocationID = "ReminderLocationID"
    private let ReminderLocationPickerID = "ReminderLocationPickerID"
    private let ReminderCategoiesID = "ReminderCategoiesID"
    private let ReminderTagID = "ReminderTagID"
    private let ReminderTagPickerID = "ReminderTagPickerID"
    private let ReminderNotesID = "ReminderNotesID"
    
    let ReminderDatePickerTag = 11  // View tag identifying the date picker cell
    private let toggleReminderTag = 20
    private let toggleLocationTag = 21
    private let CategoryTag = 30
    
    let AlarmRow = 1      // index of row containing the "Alarm"
    
    var displayedDate: Date!
    
    // Keep track of which indexPath points to cell with Remind me on date
    var remindMeOnDateIndexPath: IndexPath?
    
    // Height of date picker view
    private var datePickerCellRowHeight: CGFloat = 0.0
    
    // Keep track of which indexPath points to cell with UIDatePicker
    var datePickerIndexPath: IndexPath?
    
    private let ReminderNumberOfRowsWithTagsPicker = 3     // Number of rows when date picker is shown
    private let ReminderNumberOfRowsWithoutTagsPicker = 2   // Number of rows when date picker is hidden
    
    // Keep track of which indexPath points to cell with TagPicker
    var tagsPickerIndexPath: IndexPath?

    // Keep track of which indexPath points to cell with Alarm
    private var alarmIndexPath: IndexPath?
    
    private enum Segue {
        static let categorySegue = "categorySegue"
        static let showRepeatVC = "ShowRepeatVC"
    }
    
    private var currentTagIndex = 0
    private var allTags: [Tag]?

    // MARK: - IBOutlets
    var toggleReminderStatus: Bool = false
    var toggleLocationReminderStatus: Bool = false
    
    var horizontalScrollerView = HorizontalScrollerView()
    
    // MARK: - Properties
    var task: Task?
    
    // MARK: - EventKits
    var isAccessToEventStoreGranted: Bool = false
    var eventStore: EKEventStore = EKEventStore()
    
    var tasks: [Task] = []

    // Alarm
    var taskReminder: EKReminder?
    var allReminders: [EKReminder] = []
    
    // Title TextView
    var titleTextView = UITextView()
    var notesTextView = UITextView()

    // MARK: - View life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTags()
        allTags = fetchedResultsController.fetchedObjects
        setupView()
        hideKeyboardWhenTappedAround()
        setupNotificationHandling()
    }
    
    deinit {
       // print("Details Was deinited")
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self,
                                          name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                          object: nil)
    }
    
    private func setupView() {
        title = "Details"
        setupTableView()
        setupHorizontalScrollerView()
        
        self.displayedDate = Date()
        
        if (task?.hasAlarm)! {
            toggleReminderStatus = true
            
            self.allReminders = TimedReminderStore.shared.allReminders
            
            // Fetch Reminder matching with Task
            for reminder in self.allReminders.reversed() {
                if reminder.title == task?.title! {
                    self.taskReminder = reminder
                    self.displayedDate = taskReminder?.alarms?.first?.absoluteDate
                    
                    
                    break
                }
            }
        }
        else {
            toggleReminderStatus = false
        }
        
        if (task?.hasLocationReminder)! {
            toggleLocationReminderStatus = true
            
        }
        else {
            toggleLocationReminderStatus = false
        }
    }
    
    // MARK: - Prepare

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        
        switch (identifier) {
        case Segue.categorySegue:
            guard let categoriesVC = segue.destination as? CategoriesVC else {return}
            
            // Configure categoriesVC
            categoriesVC.task = task
            
        case Segue.showRepeatVC:
            guard let repeatVC = segue.destination as? RepeatVC else { return }
            
            let cell = sender as! UITableViewCell
            
            // Configure repeatVC
            repeatVC.displayedFrequency = cell.detailTextLabel?.text
            
        default:
            break
        }
    }
    
    // MARK: - UnwindSegueToDetailsVC
    @IBAction func unwindToDetailsVC (segue: UIStoryboardSegue) {
        let repeatVC = segue.source as! RepeatVC
        
        var frequencyCell: UITableViewCell? = nil
        
        // The frequency cell is at row 3 when the date picker is shown and at row 2, otherwise
        if self.hasInlineDatePicker {
            frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 1))
        } else {
            frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1))
        }
        // Display the frequency value
        frequencyCell?.detailTextLabel?.text = repeatVC.displayedFrequency
    }

    
    // MARK: - Tag
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Tag> = {
        guard let managedObjectContext = self.task?.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "colorName", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    private func fetchTags() {
        do {
            try self.fetchedResultsController.performFetch()
            
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }

    // MARKL - Actions
    
    @IBAction func doneButtonWasPressed(_ sender: UIBarButtonItem) {
        
        // Title
        guard let title = titleTextView.text, !title.isEmpty else {
            showAlert(with: "Error", and: "Title can't not empty")
            return
        }
        task?.title = title
        
        
        if toggleReminderStatus {
            // Start Date
            let startDate = self.displayedDate
            
            // Frequency
            var frequencyCell: UITableViewCell? = nil
            if self.hasInlineDatePicker {
                frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 1))
            } else {
                frequencyCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1))
            }
            let frequency = frequencyCell?.detailTextLabel!.text
            
            // Create Reminder
            var reminder = TimedReminder(title: titleTextView.text,
                                         startDate: startDate!,
                                         frequency: frequency!)
            
            if let taskReminder = self.taskReminder {
                // Modify Reminder
                TimedReminderStore.shared.updateReminder(taskReminder, reminder)
            }
            else {
                // Create Reminder
                TimedReminderStore.shared.createReminder(&reminder)
                task?.calendarIdentifier = reminder.calendarIdentifier
            }
            task?.hasAlarm = true
        }
        else {
            task?.hasAlarm = false
            
            if taskReminder != nil {
                // Remove Reminder
                TimedReminderStore.shared.remove(taskReminder!)
            }
            
        }
        
        
        
        // Dismiss Details View Controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchToggleReminderValueChanged(_ sender: UISwitch) {

        // Check Permission Acess Reminder
 //       TimedReminderStore.shared.checkEventStoreAuthorizationStatus()
       
        self.tableView.beginUpdates()                            // TableView begin update
        
        let indexPath = tableView.indexPath(for: sender)
        
        if sender.isOn {
            self.displayedDate = Date()
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1))
            cell?.detailTextLabel?.text = HelperClass.dateFormatterShort.string(from: self.displayedDate)
            
            toggleReminderStatus = true
            self.addAlarmAndRepeatAtIndexPath(indexPath!)
            
        }
        else {
            toggleReminderStatus = false
            self.hideAlarmAndRepeatAtIndexPath(indexPath!)
        }
        
        self.tableView.endUpdates()                               // TableView endUpdate
        
    }
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DetailsTableVC {
    private func setupTableView() {
        tableView.alwaysBounceHorizontal = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 5 }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerSectionTitle: String? = nil
        
        switch section {
        case 0:
            headerSectionTitle = "Title"
        case 4:
            headerSectionTitle = "Notes"
        default:
            break
        }
        return headerSectionTitle
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
    
        if section == 1 {
            if toggleReminderStatus && self.hasInlineDatePicker {
                // Return 4 rows if the Date Picker is shown and ToggleReminder is On
                numberOfRows = 4
            }
            else if toggleReminderStatus && !self.hasInlineDatePicker {
                // Return 3 rows if the Date Picker is hidden and ToggleReminder is On
                numberOfRows = 3
            }
            // Otherwise return 1 row
        }
            
        else if section == 2 {
            // Reminder Location
            if toggleLocationReminderStatus {
                numberOfRows = 2
            }
            else {
                numberOfRows = 1
            }
            
        }
            
        else if section == 3 {
            // Reminder Tag
            numberOfRows = self.hasInlineTagsPicker ? ReminderNumberOfRowsWithTagsPicker : ReminderNumberOfRowsWithoutTagsPicker
        }
    
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellID: String? = nil
        switch indexPath.section {
        case 0:
            cellID = ReminderTitleID
        case 1:
            
            if self.indexPathHasDatePicker(indexPath) {
                cellID = ReminderDatePickerID
            } else if self.indexPathHasAlarm(indexPath) {
                cellID = ReminderAlarmID
            } else if indexPath.row == 0 {
                cellID = ReminderRemindMeOnDateID
            }
            else {
                cellID = ReminderFrequencyID
            }
            
        case 2:
            if indexPath.row == 0 {
                cellID = ReminderLocationID
            }
            else {
                cellID = ReminderLocationPickerID
            }
        case 3:
            if indexPath.row == 0 {
                cellID = ReminderCategoiesID
            }
            else if indexPath.row == 1 {
                cellID = ReminderTagID
            }
            else {
                cellID = ReminderTagPickerID
            }
            
        case 4:
            cellID = ReminderNotesID
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID!, for: indexPath)
        
        switch cellID {
            case ReminderTitleID:
                cell.contentView.addSubview(titleTextView)
                layoutTextView(cell, textView: titleTextView)
                titleTextView.text = task?.title
                titleTextView.delegate = self
            
            case ReminderRemindMeOnDateID:
                guard let _ = task else { return UITableViewCell() }
                
                cell.selectionStyle = .none
                guard let toggleReminder = cell.viewWithTag(toggleReminderTag) as? UISwitch else {  return UITableViewCell() }
                toggleReminder.isOn = toggleReminderStatus ? true : false
        case ReminderAlarmID:
            if !self.hasInlineDatePicker {
                cell.textLabel?.text = "Alarm"
                cell.textLabel?.textColor = .black
                
                cell.detailTextLabel?.text = HelperClass.dateFormatterShort.string(from: self.displayedDate)
            }
            
            case ReminderLocationID:
                guard let toggleLocationReminder = cell.viewWithTag(toggleLocationTag) as? UISwitch else { return UITableViewCell()}
                toggleLocationReminder.isOn = self.toggleLocationReminderStatus ? true : false
            
            case ReminderTagPickerID:
                cell.contentView.addSubview(horizontalScrollerView)
                layoutHorizontalScrollerView(cell)
            
            case ReminderCategoiesID:
                cell.detailTextLabel?.text = task?.category?.name
                cell.detailTextLabel?.textColor = .blue
            
            case ReminderNotesID:
                    cell.contentView.addSubview(notesTextView)
                    layoutTextView(cell, textView: notesTextView)
                    notesTextView.text = task?.content ?? "Add some notes..."
                    notesTextView.delegate = self
            
            default: break
        }
        return cell
    }
    
    fileprivate func layoutHorizontalScrollerView(_ tableViewCell: UITableViewCell) {
        horizontalScrollerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalScrollerView.topAnchor.constraint(equalTo: tableViewCell.contentView.topAnchor, constant: 0),
            horizontalScrollerView.bottomAnchor.constraint(equalTo: tableViewCell.contentView.bottomAnchor, constant: 0),
            horizontalScrollerView.leadingAnchor.constraint(equalTo: tableViewCell.contentView.leadingAnchor, constant: 0),
            horizontalScrollerView.trailingAnchor.constraint(equalTo: tableViewCell.contentView.trailingAnchor, constant: 0)
        ])
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let cellID = cell?.reuseIdentifier
        let section = indexPath.section

        switch section {
        case 1:
            if cellID == ReminderAlarmID {
                self.displayDatePickerInlineForRowAtIndexPath(indexPath)
                if !self.hasInlineDatePicker {
                    cell?.textLabel?.text = "Alarm"
                    cell?.textLabel?.textColor = .black
                    cell?.detailTextLabel?.text = HelperClass.dateFormatterShort.string(from: self.displayedDate)
                }
            }

        case 3:
            if cellID == ReminderTagID {
                self.displayTagsPickerInlineForRowAtIndexPath(indexPath)
            }

        default: break
        }
    }
    
    private func updateCategoryLabel() {
        // update category
        let categoryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 3))
        guard let categoryLabel = categoryCell?.viewWithTag(CategoryTag) as? UILabel else {return}
        categoryLabel.text = task?.category?.name
    }
    
    // MARK: - Notification Handling
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        
        if (updates.filter { return $0 == task }).count > 0 {
            updateCategoryLabel()
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                       name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: task?.managedObjectContext)
    }
}



extension DetailsTableVC: HorizontalScrollerViewDelegate {
    private func setupHorizontalScrollerView() {
        horizontalScrollerView.backgroundColor = .white
        horizontalScrollerView.dataSource = self
        horizontalScrollerView.delegate = self
        horizontalScrollerView.reload()
    }
    
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int) {
        
        currentTagIndex = index
        
        let tagView = horizontalScrollerView.view(at: currentTagIndex) as! TagView
        
        
        
        guard let tags = allTags else { return }
        let tag = tags[index]
        
        if isContained(tag: tag) {
            task?.removeFromTag(tag)
            tagView.highlightTag(false)
        }
        else {
            task?.addToTag(tag)
            tagView.highlightTag(true)
        }
    }

    
    private func isContained(tag: Tag) -> Bool {
        if let containsTag = task?.tag?.contains(tag), containsTag == true {
            return true
        }
        else {
            return false
        }
    }
}

extension DetailsTableVC: HorizontalScrollerViewDataSource {
    func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int {
        if let tags = allTags {
            return tags.count
        }
        return 0
    }
    
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView {
        guard let tags = allTags else { return UIView() }
        let tag = tags[index]
        let tagView = TagView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), tagColor: tag.colorName!)
        
        //let indexPath = IndexPath(row: index, section: 0)
        
        isContained(tag: tag) ? tagView.highlightTag(true) : tagView.highlightTag(false)
        
        return tagView
    }
}

extension DetailsTableVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //let indexPath = IndexPath(row: 1, section: 3)
       // tableView.reloadRows(at: [indexPath], with: .none)
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
      //  updateView()
    }
}

extension DetailsTableVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        fixTextView(textView)
        tableView.endUpdates()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Add some notes..." {
            textView.text = ""
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if (textView.text == "") {
            textView.text = "Add some notes..."
        }
        else {
            task?.content = textView.text
        }
        return true
    }
    
    func layoutTextView(_ cell: UITableViewCell, textView: UITextView) {
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0),
            textView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10)
            ])
    }
}
