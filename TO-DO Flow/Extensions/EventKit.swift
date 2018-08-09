
//
//  EventKit.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/2/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import Foundation
import EventKit


//MARK: - EKRecurrenceRule Additions

//MARK: - EKRSReminderStoreUtilities

let FrequencyNever = "Never";
let FrequencyDaily = "Daily";
let FrequencyWeekly = "Weekly";
let FrequencyYearly = "Yearly";
let FrequencyMonthly = "Monthly";
let FrequencyBiweekly = "Biweekly";

extension EKRecurrenceRule {
    
    // Return the EKRecurrenceFrequency value matching a given name
    func frequencyMatchingName(_ name: String) -> EKRecurrenceFrequency {
        // Default value
        var recurrence = EKRecurrenceFrequency.daily
        
        if name == FrequencyWeekly {
            recurrence = .weekly
        } else if name == FrequencyMonthly {
            recurrence = .monthly
        } else if name == FrequencyYearly {
            recurrence = .yearly
        }
        
        return recurrence
    }
    
    
    // Return the name matching a given EKRecurrenceFrequency value
    func nameMatchingFrequency(_ frequency: EKRecurrenceFrequency) -> String {
        // Default value
        var name = FrequencyDaily
        
        switch frequency {
        case .daily:
            name = FrequencyDaily
        case .weekly:
            name = FrequencyWeekly
        case .monthly:
            name = FrequencyMonthly
        case .yearly:
            name = FrequencyYearly
        }
        
        return name
    }
    
    
    // Create a recurrence interval
    func intervalMatchingFrequency(_ frequency: String) -> Int {
        // Return 2 if the reminder repeats every two weeks and 1, otherwise
        let interval = frequency == FrequencyBiweekly ? 2 : 1
        return  interval
    }
    
    
    // Create a recurrence rule
    func recurrenceRuleMatchingFrequency(_ frequency: String) -> EKRecurrenceRule {
        // Create a recurrence interval matching the specified frequency
        let interval = self.intervalMatchingFrequency(frequency)
        // Create a weekly recurrence frequency if the reminder repeats every two  weeks. Fetch the EKRecurrenceFrequency value matching frequency, otherwise.
        let recurrenceFrequency = frequency == FrequencyBiweekly ? EKRecurrenceFrequency.weekly : self.frequencyMatchingName(frequency)
        
        // Create a recurrence rule using the above recurrenceFrequency and interval
        let rule = EKRecurrenceRule(recurrenceWith: recurrenceFrequency,
                                    interval: interval,
                                    end: nil)
        return rule
    }
    
    
    // Return the name matching a recurrence rule
    func nameMatchingRecurrenceRuleWithFrequency(_ frequence: EKRecurrenceFrequency, interval: Int) -> String {
        // Get the name matching frequency
        var name = self.nameMatchingFrequency(frequency)
        
        // A Biweekly reminder is one with a weekly recurrence frequency and an interval of 2.
        // Set name to Biweekly if that is the case.
        if interval == 2 && name == FrequencyWeekly {
            name = FrequencyBiweekly
        }
        
        return name
    }
    
}
