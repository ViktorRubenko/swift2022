//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit

class CategoryPickerViewController: UIViewController {
    
    var tableView: UITableView!
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"
    ]
    var category = "No Category"
    var callback: ((String) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Category"

        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        view.addSubview(tableView)
    }
}
//MARK: - UITableView Delegate/DataSource
extension CategoryPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = categories[indexPath.row]
        cell.contentConfiguration = config
        if categories[indexPath.row] == category {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callback(categories[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}
