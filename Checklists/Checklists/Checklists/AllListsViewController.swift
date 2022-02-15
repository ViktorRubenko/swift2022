//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Victor Rubenko on 15.02.2022.
//

import UIKit

class AllListsViewController: UITableViewController {

    let cellIdentifier = "ChecklistCell"
    var dataModel: DataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel.lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel!.text = dataModel.lists[indexPath.row].name
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowChecklist", sender: dataModel.lists[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController
            controller.checklist = sender as? Checklist
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ListDetail") as? ListDetailViewController {
            controller.delegate = self
            controller.item = dataModel.lists[indexPath.row]
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
        let row = dataModel.lists.count
        dataModel.lists.append(checklist)
        tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
    
    
}
