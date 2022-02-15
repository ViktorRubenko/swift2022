//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Victor Rubenko on 15.02.2022.
//

import UIKit

class AllListsViewController: UITableViewController {

    let cellIdentifier = "ChecklistCell"
    var checklists = [Checklist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        
        loadChecklists()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checklists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel!.text = checklists[indexPath.row].name
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowChecklist", sender: checklists[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController
            controller.checklist = sender as? Checklist
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        checklists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ListDetail") as? ListDetailViewController {
            controller.delegate = self
            controller.item = checklists[indexPath.row]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc func addItem() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ListDetail") as? ListDetailViewController {
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension AllListsViewController: ListDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist) {
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        navigationController?.popViewController(animated: true)
        let row = checklists.count
        checklists.append(checklist)
        tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
    
    
}

// MARK: - Date Persistence

extension AllListsViewController {
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(checklists)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }
    
    func loadChecklists() {
        let decoder = PropertyListDecoder()
        do {
            let data = try Data(contentsOf: dataFilePath())
            checklists = try decoder.decode([Checklist].self, from: data)
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
        }
    }
}
