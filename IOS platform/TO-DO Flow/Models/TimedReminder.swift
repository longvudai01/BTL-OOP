//
//  TimedReminder.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/1/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import Foundation

struct TimedReminder {

    // Reminder's priority
    // var priority: String?
    
    // Reminder Title
    var title: String?
    
    // Reminder's recurrence frequency
    var frequency: String?
    
    // Reminder's start date
    var startDate: Date?
    
    // Calendar Identifier
    var calendarIdentifier: String!
    
    init(title: String, startDate: Date, frequency: String) {
        self.title = title
        self.startDate = startDate
        self.frequency = frequency
    }
    
}
