//
//  DetailsTableVC+ShowAndHideCell.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/30/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

// MARK: - Show Date Picker
extension DetailsTableVC {
    // Handle Date Picker
    var hasInlineDatePicker: Bool {
        return self.datePickerIndexPath != nil
    }
    
    // Determines if the given indexPath points to a cell that contains UIDatePicker
    func indexPathHasDatePicker(_ indexPath: IndexPath) -> Bool {
        guard indexPath.section == 1 else {return false}
        return self.hasInlineDatePicker && self.datePickerIndexPath?.row == indexPath.row
    }
    
    // Determines if the given indexPath points to a cell that contains the start/end dates.
    func indexPathHasAlarm(_ indexPath: IndexPath) -> Bool {
        var hasAlarm = false
        if indexPath.row == AlarmRow { hasAlarm = true }
        return hasAlarm
    }
    
    // Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath"
    func displayDatePickerInlineForRowAtIndexPath(_ indexPath: IndexPath) {
        self.tableView.beginUpdates()
        
        // Show the picker if date cell was selected and picker is not shown
        if self.hasInlineDatePicker {
            self.hideItemAtIndexPath(indexPath)
            self.datePickerIndexPath = nil
            
            // Hide the picker if date cell was selected and picker is shown
        } else {
            self.addItemAtIndexPath(indexPath)
            self.datePickerIndexPath = IndexPath(row: indexPath.row+1, section: 1)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableView.endUpdates()
        self.updateDatePicker()
    }
    
    
    // Add the date picker view to the UI
    private func addItemAtIndexPath(_ indexPath: IndexPath) {
        let indexPaths = [IndexPath(row: indexPath.row+1, section: indexPath.section)]
        self.tableView.insertRows(at: indexPaths, with: .fade)
    }
    
    
    // Remove the date picker view to the UI
    private func hideItemAtIndexPath(_ indexPath: IndexPath) {
        let indexPaths = [IndexPath(row: indexPath.row+1, section: indexPath.section)]
        self.tableView.deleteRows(at: indexPaths, with: .fade)
    }
    
    // Update the UIDatePicker's value to match with the date of the cell above it
    private func updateDatePicker() {
        if let indexPath = self.datePickerIndexPath {
            let datePickerCell = self.tableView.cellForRow(at: indexPath)!
            
            if let datePicker = datePickerCell.viewWithTag(ReminderDatePickerTag) as? UIDatePicker {
                datePicker.date = self.displayedDate
            }
        }
    }
    
    // Called when the user selects a date from the date picker view. Update the displayed date.
    @IBAction func datePickerValueChanged(_ datePicker: UIDatePicker) {
        if self.hasInlineDatePicker {
            let dateCellIndexPath = IndexPath(row: self.datePickerIndexPath!.row-1, section: 1)
            
            let cell = self.tableView.cellForRow(at: dateCellIndexPath)
            // Update the displayed date
            cell?.textLabel?.text = HelperClass.dateFormatterFull.string(from: datePicker.date)
            cell?.textLabel?.textColor = .blue
            cell?.detailTextLabel?.text = ""
            self.displayedDate = datePicker.date
        }
    }
    
}

// MARK: - Show Tags Picker
extension DetailsTableVC {
    var hasInlineTagsPicker: Bool {
        return self.tagsPickerIndexPath != nil
    }
    
    // Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath"
    func displayTagsPickerInlineForRowAtIndexPath(_ indexPath: IndexPath) {
        self.tableView.beginUpdates()
        
        // Show the picker if date cell was selected and picker is not shown
        if self.hasInlineTagsPicker {
            self.hideItemAtIndexPath(indexPath)
            self.tagsPickerIndexPath = nil
            
            // Hide the picker if date cell was selected and picker is shown
        }
        else {
            self.addItemAtIndexPath(indexPath)
            self.tagsPickerIndexPath = IndexPath(row: indexPath.row+1, section: 1)
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.endUpdates()
    }
}

// MARK: - Show Remind Me On Date
extension DetailsTableVC {
    
    // Add the Alarm and Repeat view to the UI
    func addAlarmAndRepeatAtIndexPath(_ indexPath: IndexPath) {
        let indexPaths = [IndexPath(row: indexPath.row+1, section: 1),
                          IndexPath(row: indexPath.row+2, section: 1)]
        self.tableView.insertRows(at: indexPaths, with: .fade)
    }
    
    
    // Remove the Alarm view to the UI
    func hideAlarmAndRepeatAtIndexPath(_ indexPath: IndexPath) {
        var indexPaths = [IndexPath(row: indexPath.row+1, section: 1),
                          IndexPath(row: indexPath.row+2, section: 1)]
        
        if self.hasInlineDatePicker {
            self.datePickerIndexPath = nil
            indexPaths.append(IndexPath(row: indexPath.row+3, section: 1))
        }
        self.tableView.deleteRows(at: indexPaths, with: .fade)
    }
}
