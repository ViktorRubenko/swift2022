//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 19.02.2022.
//

import UIKit

class CategoryPickerViewController: UIViewController {

    var selectedCategoryName = ""
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
    
    var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func loadView() {
        super.loadView()
        
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
    }

}


extension CategoryPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.accessoryType = .checkmark
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.text = categories[indexPath.row]
        cell.contentConfiguration = contentConfiguration
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategoryName = categories[indexPath.row]
        print(selectedCategoryName)
    }
}
