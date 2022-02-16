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
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        let index = dataModel.indexOfSelectedChecklist
        if index != -1 && index < dataModel.lists.count {
            let checklist = dataModel.lists[dataModel.indexOfSelectedChecklist]
            performSegue(withIdentifier: "ShowChecklist", sender: checklist)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataModel.lists.count
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.accessoryType = .detailDisclosureButton
        
        let checklist = dataModel.lists[indexPath.row]
        
        var content = UIListContentConfiguration.subtitleCell()
        content.text = checklist.name
        let count = checklist.countUncheckedItems()
        if checklist.items.count == 0 {
            content.secondaryText = "(No Items)"
        } else {
            content.secondaryText = count == 0 ? "All Done" : "\(count) remaning"
        }
        content.image = UIImage(named: checklist.iconName)
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataModel.indexOfSelectedChecklist = indexPath.row
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
        dataModel.sortChecklists()
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist) {
        navigationController?.popViewController(animated: true)
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
    }
}

extension AllListsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            dataModel.indexOfSelectedChecklist = -1
        }
    }
}
