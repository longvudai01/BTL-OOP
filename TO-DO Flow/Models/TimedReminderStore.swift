//
//  TimedReminderStore.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/2/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI

class TimedReminderStore: ReminderStore {
    static let shared = TimedReminderStore()

    // MARK: - Create time-based Reminder
    func createReminder(_ reminder: inout TimedReminder) {
        let myReminder = EKReminder(eventStore: self.eventStore)
        
        myReminder.title = reminder.title
        myReminder.calendar = self.calendar
        /* add priority */
        
        // Create the date components of the reminder's start date components
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        let unitFlats: Set<Calendar.Component> = [.second, .minute, .hour, .month, .year, .day]
        var dateComponents = gregorian.dateComponents(unitFlats, from: reminder.startDate!)
        dateComponents.timeZone = myReminder.timeZone
        
        // For iOS apps, EventKit requires a start date if a due date was set
        myReminder.startDateComponents = dateComponents
        myReminder.dueDateComponents = dateComponents
        
        // Create a recurrence rule if the reminder repeats itself over a given period of time
        if reminder.frequency != FrequencyNever {
            let rule = EKRecurrenceRule()
            
            // Recurrence rule matching with reminder
            let recurrenceRule = rule.recurrenceRuleMatchingFrequency(reminder.frequency!)
            
            // Apple to Reminder
            myReminder.addRecurrenceRule(recurrenceRule)
        }
        
        // Create an Alarm
        let alarm = EKAlarm(absoluteDate: reminder.startDate!)
        myReminder.addAlarm(alarm)
        
        reminder.calendarIdentifier = myReminder.calendarItemIdentifier
        
        // Save Reminder
        self.save(myReminder)
        
    }
    
    // MARK: - Modify time-based Reminder
    func updateReminder(_ taskReminder: EKReminder, _ reminder: TimedReminder) {
        
        taskReminder.title = reminder.title
        taskReminder.calendar = self.calendar
        /* add priority */
        
        // Create the date components of the reminder's start date components
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        let unitFlats: Set<Calendar.Component> = [.second, .minute, .hour, .month, .year, .day]
        var dateComponents = gregorian.dateComponents(unitFlats, from: reminder.startDate!)
        dateComponents.timeZone = taskReminder.timeZone
        
        // For iOS apps, EventKit requires a start date if a due date was set
        taskReminder.startDateComponents = dateComponents
        taskReminder.dueDateComponents = dateComponents
        
        if taskReminder.hasRecurrenceRules {
            guard let rule = taskReminder.recurrenceRules?.first else { return }
            let frequency = rule.nameMatchingFrequency(rule.frequency)
            
            if reminder.frequency != frequency && reminder.frequency != FrequencyNever {
                for rule in taskReminder.recurrenceRules! {
                    taskReminder.removeRecurrenceRule(rule)
                }
                
                let rule = EKRecurrenceRule()
                
                // Recurrence rule matching with reminder
                let recurrenceRule = rule.recurrenceRuleMatchingFrequency(reminder.frequency!)
                
                // Apple to Reminder
                taskReminder.addRecurrenceRule(recurrenceRule)
            }
        }
        else {
            if reminder.frequency != FrequencyNever {                
                let rule = EKRecurrenceRule()
                
                // Recurrence rule matching with reminder
                let recurrenceRule = rule.recurrenceRuleMatchingFrequency(reminder.frequency!)
                
                // Apple to Reminder
                taskReminder.addRecurrenceRule(recurrenceRule)
            }
        }
        
        // if task Reminder has Alarms then remove it
        if taskReminder.hasAlarms {
            for alarm in taskReminder.alarms! {
                taskReminder.removeAlarm(alarm)
            }
        }
        
        let alarm = EKAlarm(absoluteDate: reminder.startDate!)
        taskReminder.addAlarm(alarm)
        
        print("Update reminder")
        save(taskReminder)

    }
}
