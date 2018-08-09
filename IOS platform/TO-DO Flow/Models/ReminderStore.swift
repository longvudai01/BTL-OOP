//
//  ReminderStore.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/2/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit
import EventKit

class ReminderStore: NSObject {
    var eventStore: EKEventStore
    var calendar: EKCalendar?
    
    // Specifies the type of calendar being created
 //   var calendarName: String?
    
    // Error encountered while saving or removing a reminder
    var errorMessage: String?
    
    var allReminders: [EKReminder] = []
    
    // Keep track of all past-due reminders
//    var pastDueReminders: [EKReminder] = []
    
    // Keep track of all upcoming reminders
    var upcomingReminders: [EKReminder] = []
    // Keep track of all completed reminders
//    var completedReminders: [EKReminder] = []
    // Keep track of location reminders
  //  var locationReminders: [EKReminder] = []
    let notificationCenter = NotificationCenter.default
    
    override init() {
        eventStore = EKEventStore()
        
        super.init()
        notificationCenter.addObserver(self,
                                       selector: #selector(storeChanged(_:)),
                                       name: NSNotification.Name.EKEventStoreChanged,
                                       object: eventStore)
    }
    
    //MARK: - Reminders Access Methods
    
    func checkEventStoreAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            self.accessGrantedForReminders()
        case .notDetermined:
            self.requestEventStoreAccessForReminders()
        case .denied, .restricted:
            self.accessDeniedForReminders()
        }
    }
    
    // Prompt the user for access to their Reminders app
    private func requestEventStoreAccessForReminders() {
        self.eventStore.requestAccess(to: .reminder) {granted, error in
            if granted {
                self.accessGrantedForReminders()
            } else {
                self.accessDeniedForReminders()   
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Called when the user has granted access to Reminders
    private func accessGrantedForReminders() {
        calendar = eventStore.defaultCalendarForNewReminders()
        // Notifies the listener that access was granted to Reminders
        DispatchQueue.main.async {
            self.notificationCenter.post(name: Notification.Name.AccessGrantedNotification,
                                    object: self)
        }
    }
    
    
    // Called when the user has denied or restricted access to Reminders
    private func accessDeniedForReminders() {
    }
    
    
    // Fetch all upcomming Reminder
    func fetchUpcommingReminderWithDueDate(_ endDate: Date) {
        // Predicate to fetch all incomplete Reminder starting now and ending on endDate
        let predicate = self.eventStore.predicateForIncompleteReminders(withDueDateStarting: Date(),
                                                                        ending: endDate,
                                                                        calendars: [self.calendar!])
        
        // Fetch reminders matching above predicate
        self.eventStore.fetchReminders(matching: predicate) { reminders in
            self.upcomingReminders = reminders ?? []
        }
    }
    
    // Fetch All reminder
    func fetchAllReminders() {
        let predicate = self.eventStore.predicateForReminders(in: nil)
        
        // Fetch Reminders matching with above predicate
        self.eventStore.fetchReminders(matching: predicate) { reminders in
            self.allReminders = reminders ?? []
        }
    }
    
    // Fetch Reminder With CalendarItemIdentifier
    func fetchReminderWithCalendarItemIdentifier (with identifier: String) -> EKCalendarItem? {
        let calendarItem = self.eventStore.calendarItem(withIdentifier: identifier)
        return calendarItem
    }
   
    
    
    //MARK: - Handle EKEventStoreChangedNotification
    
    @objc func storeChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.notificationCenter.post(name: Notification.Name.RefreshDataNotification,
                                            object: self)
        }
    }
    
    
    //MARK: - Save Reminder
    
    // Save reminder
    // Save the reminder to the event store
    func save(_ reminder: EKReminder) {
        do {
            print("saved reminder \(reminder.calendarItemIdentifier)")
            try self.eventStore.save(reminder, commit: true)
            
            // Notifies the listener that the operation was successful
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.RefreshDataNotification,
                                                object: self)
            }
            
        } catch let error {
            // Keep track of the error message encountered
            self.errorMessage = error.localizedDescription
            print(errorMessage!)
        }
    }
    
    //MARK: - Remove Reminder
    
    // Delete reminder
    // Remove reminder from the event store
    func remove(_ reminder: EKReminder) {
        do {
            print("Remove reminder \(reminder.calendarItemIdentifier)")
            try self.eventStore.remove(reminder, commit: true)
            
            // Notifies the listener that the operation was successful
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.RefreshDataNotification,
                                                object: self)
            }
          
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print(errorMessage!)
        }
    }
    
   
    
    //MARK: - Memory Management
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.EKEventStoreChanged,
                                                  object: nil)
    }
}


