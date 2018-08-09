//
//  CategoryCell.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/25/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var folderButton: UIButton!
    
    @IBOutlet weak var categoryNameTexField: UITextField!
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    static let reuseIdentifier = "CategoryCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
