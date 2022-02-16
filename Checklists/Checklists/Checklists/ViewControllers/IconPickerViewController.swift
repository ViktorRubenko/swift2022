//
//  IconPickerViewController.swift
//  Checklists
//
//  Created by Victor Rubenko on 16.02.2022.
//

import UIKit


protocol IconPickerViewControllerDelegate: AnyObject {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String)
}

class IconPickerViewController: UITableViewController {

    weak var delegate: IconPickerViewControllerDelegate?
    
    let icons = ["No Icon", "Appointments", "Birthdays", "Chores", "Drinks", "Folder", "Groceries", "Inbox", "Photos", "Trips"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "iconCell")
        var content = UIListContentConfiguration.cell()
        content.image = UIImage(named: icons[indexPath.row])
        content.text = icons[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.iconPicker(self, didPick: icons[indexPath.row])
    }

}
