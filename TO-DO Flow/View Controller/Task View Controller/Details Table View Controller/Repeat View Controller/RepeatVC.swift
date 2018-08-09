//
//  RepeatVC.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/2/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

class RepeatVC: UITableViewController {

    // keep track of displayed Frequency
    var displayedFrequency: String?
    
    fileprivate let frequenciesList = "FrequenciesList"
    
    // Cell Identifier
    private let RepeatVCCellID = "FrequencyCell"
    
    private var frequencies: [[String : String]] = []
    private var crtFrequencyOpt: [String : String] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Repeat"
        fetchFrequenciesList()
        print(displayedFrequency as Any)
    }
    
    deinit {
        print("repeat VC was deinitted")
    }

    // Fetch all frequencies and deescription value
    fileprivate func fetchFrequenciesList() {
        let listURL = Bundle.main.url(forResource: frequenciesList, withExtension: "plist")!
        self.frequencies = NSArray(contentsOf: listURL) as! [[String : String]]
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frequencies.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let frequency = frequencies[indexPath.row]
        
        // Add checkmark for selected row
        if frequency["title"] == self.displayedFrequency {
            self.crtFrequencyOpt = frequency
            cell.accessoryType = .checkmark
        }
        
        cell.textLabel?.text = frequency["title"]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: RepeatVCCellID, for: indexPath)
    }
    
    // TableView delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let indexOfCurrenttOpt = self.frequencies.index { $0 == self.crtFrequencyOpt }!
        
        // Check wheather the same row was selected and return, if it was
        if indexOfCurrenttOpt == indexPath.row { return }
        
        let oldIndexPath = IndexPath(row: indexOfCurrenttOpt, section: 0)
        
        let oldCell = tableView.cellForRow(at: oldIndexPath)
        if oldCell?.accessoryType == .checkmark {
            oldCell?.accessoryType = .none
        }
        
        let newCell = tableView.cellForRow(at: indexPath)!
        if newCell.accessoryType == .none {
            newCell.accessoryType = .checkmark
            self.crtFrequencyOpt = frequencies[indexPath.row]
        }
        
    }
    
    // MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        
        self.displayedFrequency = frequencies[(indexPath.row)]["title"]
    }
    
    //MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
