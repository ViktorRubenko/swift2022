//
//  LocaitonDetailsViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 19.02.2022.
//

import UIKit
import CoreLocation

class LocationDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationItem()
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
    }
    
    // MARK: - Helper Methods
    
    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        var contentConfiguration = cell.defaultContentConfiguration()
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.selectionStyle = .none
        case (0, 1):
            contentConfiguration.text = "Category"
            contentConfiguration.secondaryText = categoryName
            cell.accessoryType = .disclosureIndicator
            cell.contentConfiguration = contentConfiguration
        case (1, 0):
            contentConfiguration.text = "Photo"
            cell.accessoryType = .disclosureIndicator
            cell.contentConfiguration = contentConfiguration
        case (2, 0):
            contentConfiguration.text = "Latitude"
            contentConfiguration.secondaryText = String(format: "%.8f", coordinate.latitude)
            cell.contentConfiguration = contentConfiguration
            cell.selectionStyle = .none
        case (2, 1):
            contentConfiguration.text = "Longitude"
            contentConfiguration.secondaryText = String(format: "%.8f", coordinate.longitude)
            cell.contentConfiguration = contentConfiguration
            cell.selectionStyle = .none
        case (2, 2):
            if let cell = cell as? TwoLabelsCell {
                let address: String
                cell.leftLabel.text = "Address"
                if let placemark = placemark {
                    address = String(placemark)
                } else {
                    address = "No Address Found"
                }
                cell.rightLabel.text = address
            }
            cell.selectionStyle = .none
        case (2, 3):
            contentConfiguration.text = "Date"
            contentConfiguration.secondaryText = currentDate()
            cell.contentConfiguration = contentConfiguration
            cell.selectionStyle = .none
        default:
            break
        }
    }
    
    func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd.MM.yyyy"
        return formatter.string(from: Date())
    }
    
    // MARK: - Actions
    
    @objc func done() {
        navigationController?.popViewController(animated: true)
    }
    
    func showCategoryPicker() {
        let controller = CategoryPickerViewController()
        controller.selectedCategoryName = categoryName
        controller.callback = {[weak self] categoryName in
            self?.categoryName = categoryName
            self?.tableView.reloadData()
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 4
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell = Bundle.main.loadNibNamed("DescriptionCell", owner: self, options: nil)?.first as! DescriptionCell
        case (1, 0):
            cell = UITableViewCell()
        case (2, 2):
            cell = TwoLabelsCell()
        default:
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            showCategoryPicker()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Description"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section, indexPath.row) == (0, 0) {
            return 88
        } else {
            return 44
        }
    }

}
