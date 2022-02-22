//
//  LocaitonDetailsViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 19.02.2022.
//

import UIKit
import CoreLocation
import CoreData
import PhotosUI

class LocationDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, managedObjectContextProtocol {

    var tableView: UITableView!
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var date = Date()
    var descriptionText = ""
    var image: UIImage?
    var photoText = "Add Photo"
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                placemark = location.placemark
                categoryName = location.category
                date = location.date
                descriptionText = location.locationDescription
            }
        }
    }
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationItem()
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        tableView.register(PhotoCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.estimatedRowHeight = 280
        tableView.rowHeight = UITableView.automaticDimension
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        view.addSubview(tableView)
    }
    
    // MARK: - Helper Methods
    
    func configureNavigationItem() {
        if locationToEdit != nil {
            navigationItem.title = "Edit Location"
        } else {
            navigationItem.title = "Add Location"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        var contentConfiguration = cell.defaultContentConfiguration()
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            (cell as! DescriptionCell).textView.text = descriptionText
            cell.selectionStyle = .none
        case (0, 1):
            contentConfiguration.text = "Category"
            contentConfiguration.secondaryText = categoryName
            cell.accessoryType = .disclosureIndicator
            cell.contentConfiguration = contentConfiguration
        case (1, 0):
            cell.accessoryType = .disclosureIndicator
            (cell as! PhotoCell).leftLabel.text = photoText
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
        return formatter.string(from: date)
    }
    
    func showImage(image: UIImage) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! PhotoCell
        cell.imageHeight.constant = 260
        cell.photoImage = image
        photoText = ""
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc func done() {
        guard let mainView = navigationController?.parent?.view else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        let location: Location
        
        if let temp = locationToEdit {
            location = temp
            hudView.text = "Updated"
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
        }
        
        location.locationDescription = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DescriptionCell).textView.text
        location.date = date
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.category = categoryName
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                hudView.hide()
                self?.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalError("Error \(error)")
        }
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
    
    @objc func hideKeyBoard(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if let indexPath = indexPath {
            if indexPath.section == 0 && indexPath.row == 0 {
                return
            }
        }
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DescriptionCell
        cell.textView.resignFirstResponder()
    }
    
    func pickPhoto() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        present(pickerViewController, animated: true)
    }
    
    func takePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.takePhoto()
        }))
        alert.addAction(
            UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            self?.pickPhoto()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
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
            cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath)
        case (1, 0):
            cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
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
        case (0, 0):
            let cell = tableView.cellForRow(at: indexPath) as! DescriptionCell
            cell.textView.becomeFirstResponder()
        case (0, 1):
            showCategoryPicker()
        case (1, 0):
            showPhotoMenu()
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
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1{
            return indexPath
        }
        return nil
    }

}

extension LocationDetailsViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.image = image
                        self.showImage(image: image)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
    }
}
