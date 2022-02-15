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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        items.append(ChecklistItem(text: "Walk the dog"))
        items.append(ChecklistItem(text: "Brush my teeth"))
        items.append(ChecklistItem(text: "Learn iOS development"))
        items.append(ChecklistItem(text: "Soccer practice"))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
        } else if segue.identifier == "EditItem" {
            let controller = segue.destination as! ItemDetailViewController
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.item = items[indexPath.row]
            }
        }
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
        let checkLabel = cell.viewWithTag(1001) as! UILabel
        label.text = item.text
        checkLabel.text = item.checked ? "√" : ""
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension ChecklistViewController: ItemDetailViewControllerDelegate {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem) {
        navigationController?.popToRootViewController(animated: true)
        let row = items.count
        items.append(item)
        let indexPath = IndexPath(row: row, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem) {
        navigationController?.popToRootViewController(animated: true)
        tableView.reloadData()
    }
}

