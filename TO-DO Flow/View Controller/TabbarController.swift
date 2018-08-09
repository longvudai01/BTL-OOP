//
//  TabbarController.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/3/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController {

    let notificationCenter = NotificationCenter.default
    let mainQueue = OperationQueue.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Register for TimedReminderStore notifications
        let _ = notificationCenter.addObserver(forName: Notification.Name.AccessGrantedNotification,
                                               object: TimedReminderStore.shared,
                                               queue: mainQueue
        ) {[weak self] note in
            self?.handleAccessGrantedNotification(note)
        }
        
        let _ = notificationCenter.addObserver(forName: Notification.Name.RefreshDataNotification,
                                                         object: TimedReminderStore.shared,
                                                         queue: mainQueue) { [weak self] note in
                                                            self?.handleAccessGrantedNotification(note)
        }
        
        let _ = notificationCenter.addObserver(forName: Notification.Name.FailureNotification,
                                         object: TimedReminderStore.shared,
                                         queue: mainQueue
        ) {[weak self] note in
            self?.handleFailureNotification(note)
        }
        TimedReminderStore.shared.checkEventStoreAuthorizationStatus()
    }
    
    //MARK: - Handle Access Granted Notification
    
    // Handle the RSAccessGrantedNotification notification
    private func handleAccessGrantedNotification(_ notification: Notification) {
        self.accessGrantedForReminders()
    }
    
    // Access was granted to Reminders. Fetch past-due, pending, and completed reminders
    private func accessGrantedForReminders() {
        TimedReminderStore.shared.fetchAllReminders()
      //  TimedReminderStore.shared.fetchUpcommingReminderWithDueDate(HelperClass.dateByAddingDays(7))
    }
    
    //MARK: - Handle Failure Notification
    
    // Handle the RSFailureNotification notification.
    // An error has occured. Display an alert with the error message.
    private func handleFailureNotification(_ notification: Notification) {
        let myNotification = notification.object as! TimedReminderStore?
        
        let alert = HelperClass.alert(title: NSLocalizedString("Status", comment: ""),
                                      message: myNotification?.errorMessage ?? "")
        self.present(alert, animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // Unregister for TimedTabBarController notifications
        notificationCenter.removeObserver(self,
                                          name: Notification.Name.AccessGrantedNotification,
                                          object: nil)
        
        notificationCenter.removeObserver(self,
                                          name: Notification.Name.RefreshDataNotification,
                                          object: nil)
        
        notificationCenter.removeObserver(self,
                                          name: Notification.Name.FailureNotification,
                                          object: nil)
    }
}
