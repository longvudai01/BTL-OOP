//
//  TasksCell.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/21/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

protocol TasksCellDelegate: class {
    func swipwRight(_ tasksCell: TasksCell)
}

class TasksCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var taskTagsView: TaskTagsView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var dateAndFrequency: UILabel!
    
    @IBOutlet weak var heightTaskCellConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightTaskTagExpanded: NSLayoutConstraint!
    
    @IBOutlet weak var dateAndLabelHeightConstraint: NSLayoutConstraint!
    // MARK: - Properties
    
    var isFinished: Bool! {
        didSet {
            if isFinished {
                self.taskTitleTextView.strikeThrough(isFinished)
                
            }
            else {
                self.taskTitleTextView.strikeThrough(isFinished)
            }
        }
    }
    
    var delegate: TasksCellDelegate?
    // MARK: - Reusable Identifier
    
    static let reuseIdentifier = "TasksCell"
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Action
    func setupSwipe() {
        var swipeGesture  = UISwipeGestureRecognizer()
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right]
        for direction in directions {
            swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightView(_:)))
            taskTitleTextView.addGestureRecognizer(swipeGesture)
            swipeGesture.direction = direction
            taskTitleTextView.isUserInteractionEnabled = true
            taskTitleTextView.isMultipleTouchEnabled = true
        }
    }
    
    @objc private func swipeRightView(_ sender : UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 1.0) {
            if sender.direction == .right {
                self.delegate?.swipwRight(self)
            }
          //  self.taskTitleTextView.layoutIfNeeded()
          //  self.taskTitleTextView.setNeedsDisplay()
        }
    }
}





