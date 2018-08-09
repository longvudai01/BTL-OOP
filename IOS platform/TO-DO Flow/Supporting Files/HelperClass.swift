//
//  HelperClass.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/30/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

class HelperClass: NSObject {
    
    //MARK: - Create a Date
    
    // Create a new date by adding a given number of days to the current date
    static func dateByAddingDays(_ day: Int) -> Date {
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        var dateComponents = DateComponents()
        
        dateComponents.day = day
        
        return gregorian.date(byAdding: dateComponents, to: Date())!
    }
    
    // MARK: - DateFormatter
    
    static let dateFormatterShort: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d/MM/YY, HH:mm"
        return dateFormatter
    }()
    
    static let dateFormatterFull: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd/MM/YYYY, HH:mm"
        
        return dateFormatter
    }()
    
    //MARK: - Create Alert Dialog
    
    // Return an alert with a given title and message
    //@discardableResult
    static func alert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        
        
        let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                          style: .default,
                                          handler: {action in})
        
        alert.addAction(defaultAction)
        
        return alert
    }
}
