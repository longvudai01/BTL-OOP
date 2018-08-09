//
//  PopupView.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/9/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit


protocol PopupViewDelegate {
    func dismissView()
    func sortByGroceryList()
    func sortByDate()
    func sortByCategory()
}

class PopupView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: PopupViewDelegate?
    var tableView: UITableView!
    
    // Section 1
    var songCell: UITableViewCell = UITableViewCell()
    var artistCell: UITableViewCell = UITableViewCell()
    
    // Section 2
    var categoryCell: UITableViewCell = UITableViewCell()
    var tagCell: UITableViewCell = UITableViewCell()
    
    // Section 3
    var cancelCell: UITableViewCell = UITableViewCell()
    
    
    override init(frame: CGRect) {
        print("hihi")
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        super.init(frame: frame)
        initializeTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("hehe")
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        super.init(coder: aDecoder)
        initializeTableView()
    }
    
    func initializeTableView() {
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        
        setupTableView()
    }
    
    fileprivate func setupTableView() {
        tableView.isOpaque = false
        tableView.separatorStyle = .singleLine
        
        tableView.dataSource = self
        tableView.delegate = self
        self.addSubview(tableView)
        tableView.isOpaque = false
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        
        tableView.isScrollEnabled = false
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        tableView.layoutView(toItem: self, with: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
        if section == 0 {
            numberOfRows = 2
        }
        else if section == 1 {
            numberOfRows = 2
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.isOpaque = false
        
        //Top Left Right Corners
        let maskPathTop = UIBezierPath(roundedRect: cell.bounds,
                                       byRoundingCorners: [.topLeft, .topRight],
                                       cornerRadii: CGSize(width: 10.0, height: 10.0))
        let shapeLayerTop = CAShapeLayer()
        shapeLayerTop.frame = cell.bounds
        shapeLayerTop.path = maskPathTop.cgPath
        
        //Bottom Left Right Corners
        let maskPathBottom = UIBezierPath(roundedRect: cell.bounds,
                                          byRoundingCorners: [.bottomLeft, .bottomRight],
                                          cornerRadii: CGSize(width: 10.0, height: 10.0))
        let shapeLayerBottom = CAShapeLayer()
        shapeLayerBottom.frame = cell.bounds
        shapeLayerBottom.path = maskPathBottom.cgPath
        
        //All Corners
        let maskPathAll = UIBezierPath(roundedRect: cell.bounds,
                                       byRoundingCorners: [.topLeft, .topRight, .bottomRight, .bottomLeft],
                                       cornerRadii: CGSize(width: 10.0, height: 10.0))
        let shapeLayerAll = CAShapeLayer()
        shapeLayerAll.frame = cell.bounds
        shapeLayerAll.path = maskPathAll.cgPath
        
        let section = indexPath.section
        let row = indexPath.row
        if row == 0 && row == tableView.numberOfRows(inSection: section) - 1 {
            cell.contentView.layer.mask = shapeLayerAll
        }
        else if row == 0 {
            cell.contentView.layer.mask = shapeLayerTop
        }
        else if row == tableView.numberOfRows(inSection: section) - 1 {
            cell.contentView.layer.mask = shapeLayerBottom
        }
        cell.contentView.backgroundColor = .gray
        cell.alpha = 1
        cell.contentView.layer.masksToBounds = true
        
        let label = UILabel(frame: cell.bounds)
        
        cell.contentView.addSubview(label)
        
        if section == 0 {
            if row == 0 {
                label.text = "Grocery List"
            }
            else {
                label.text = "Date"
            }
            label.textAlignment = NSTextAlignment.left
        }
        else if section == 1 {
            if row == 0 { label.text = "Category" }
            else { label.text = "Tag" }
            label.textAlignment = .left
        }
        else {
            label.text = "Cancel"
            label.textAlignment = .center
        }
        label.textColor = .white
        label.layoutView(toItem: cell.contentView, with: 10)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            if row == 0 { return songCell }
            else { return artistCell }
            
        case 1:
            if row == 0 { return categoryCell }
            else { return tagCell }
        case 2:
            return cancelCell
        default:
            fatalError("No Cell to Return")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        let section = indexPath.section
        
        tableView.deselectRow(at: indexPath, animated: true)

        
        if section == 0 {
//            cell?.selectionStyle = .none
            if row == 0 {
                delegate?.sortByGroceryList()            }
            else {
                delegate?.sortByDate()
            }
        }
        else if section == 1 {
            if row == 0 {
                
            }
            else {
                
            }
        }
        else {
            delegate?.dismissView()
            print("dismiss")
        }
    }
}

extension UIView {
    func layoutView(toItem view: UIView, with constant: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant)
            ])
    }
}
