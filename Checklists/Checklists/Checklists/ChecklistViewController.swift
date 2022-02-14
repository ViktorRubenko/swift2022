//
//  ViewController.swift
//  Checklists
//
//  Created by Victor Rubenko on 14.02.2022.
//

import UIKit

class ChecklistViewController: UITableViewController {
    
    var items = [ChecklistItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items.append(ChecklistItem(text: "Walk the dog"))
        items.append(ChecklistItem(text: "Brush my teeth"))
        items.append(ChecklistItem(text: "Learn iOS development"))
        items.append(ChecklistItem(text: "Soccer practice"))
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        let item = items[indexPath.row]
        configureCell(for: cell, with: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let item = items[indexPath.row]
            item.checked.toggle()
            configureCell(for: cell, with: item)
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureCell(for cell: UITableViewCell, with item: ChecklistItem) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
        cell.accessoryType = item.checked ? .checkmark : .none
    }
}

