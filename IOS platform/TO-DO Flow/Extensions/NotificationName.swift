//
//  NotificationName.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/3/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let AccessGrantedNotification = Notification.Name("AccessGrantedNotification")
    static let RefreshDataNotification = Notification.Name("RefreshDataNotification")
    static let FailureNotification = Notification.Name("FailureNotification") // Sent when saving, removing, or marking a reminder as completed failed
}
