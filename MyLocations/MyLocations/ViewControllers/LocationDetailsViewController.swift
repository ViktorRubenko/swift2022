//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit
import CoreData
import PhotosUI
import CoreLocation

class LocationDetailsViewController: UIViewController, ManagedObjectContextProtocol {
    
    var managedObjectContext: NSManagedObjectContext!
    var tableView: UITableView!
    var image: UIImage?
    var category = "No Category"
    var coordinate: CLLocationCoordinate2D!
    var placemark: CLPlacemark?
    var date = Date()
    var locationDescription = ""
    
    var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.delegate = self
        }
    }
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                category = location.category
                placemark = location.placemark
                date = location.date
                coordinate = location.coordinate
                locationDescription = location.locationDescription
                image = location.photoImage
            }
        }
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(PhotoCell.self, forCellReuseIdentifier: "PhotoCell")
        tableView.register(DescriptionCell.self, forCellReuseIdentifier: "DescriptionCell")
        tableView.register(TwoLabelsCell.self, forCellReuseIdentifier: "TwoLabelsCell")
        tableView.register(AddressCell.self, forCellReuseIdentifier: "AddressCell")
        view.addSubview(tableView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        if locationToEdit != nil {
            title = "Edit Location"
        } else {
            title = "Tag Location"
        }
    }
}

// MARK: - Table View Delegate/DataSource
extension LocationDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 4
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Description"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionCell
                descriptionTextView = cell.textView
                descriptionTextView.text = locationDescription
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoLabelsCell", for: indexPath) as! TwoLabelsCell
                cell.accessoryType = .disclosureIndicator
                cell.leftLabel.text = "Category"
                cell.rightLabel.text = category
                return cell
            default:
                break
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.accessoryType = .disclosureIndicator
            cell.label.text = image != nil ? "" : "Add Photo"
            cell.photoImage = image
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoLabelsCell", for: indexPath) as! TwoLabelsCell
                cell.leftLabel.text = "Latitude:"
                cell.rightLabel.text = String(format: "%.8f", coordinate.latitude)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoLabelsCell", for: indexPath) as! TwoLabelsCell
                cell.leftLabel.text = "Longitude:"
                cell.rightLabel.text = String(format: "%.8f", coordinate.longitude)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressCell
                cell.leftLabel.text = "Address:"
                cell.rightLabel.text = placemark != nil ? String(placemark!) : ""
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoLabelsCell", for: indexPath) as! TwoLabelsCell
                cell.leftLabel.text = "Date:"
                cell.rightLabel.text = String(date)
                return cell
            default:
                break
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                descriptionTextView.becomeFirstResponder()
            case 1:
                selectCategory()
            default:
                return
            }
        case 1:
            showAddPhotoMenu()
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }
        return nil
    }
}

// MARK: - Actions
extension LocationDetailsViewController{
    @objc func done() {
        let location: Location
        
        if let locationToEdit = locationToEdit {
            location = locationToEdit
        } else {
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        
        location.locationDescription = locationDescription
        location.date = date
        location.placemark = placemark
        location.longitude = coordinate.longitude
        location.latitude = coordinate.latitude
        location.category = category
        
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL!, options: .atomic)
                } catch {
                    print("Error writing file: \(error.localizedDescription)")
                }
            }
        } else if location.hasPhoto {
            location.photoID = nil
            location.removePhotoFile()
        }
        
        do {
            try managedObjectContext.save()
            navigationController?.popViewController(animated: true)
        } catch {
            fatalError("Error \(error)")
        }
    }
    
    @objc func addPhoto() {
        showAddPhotoMenu()
    }
    
    @objc func hideKeyBoard(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    @objc func selectCategory() {
        let controller = CategoryPickerViewController()
        controller.category = category
        controller.callback = { [weak self] category in
            self?.category = category
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}
// MARK: - Helper Methods
extension LocationDetailsViewController {
    func showAddPhotoMenu() {
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.takePhotoFromCamera()
        }))
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: {  _ in
            self.addPhotoFromLibrary()
        }))
        if image != nil {
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
                self.deletePhoto()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func addPhotoFromLibrary() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func takePhotoFromCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func deletePhoto() {
        image = nil
        tableView.reloadData()
    }
}
//MARK: - PHPicker Delegate
extension LocationDetailsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if error == nil, let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.image = image
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}
//MARK: - ImagePickerControllerDelegate
extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            self.image = image
            DispatchQueue.main.async {
                self.image = image
                self.tableView.reloadData()
            }
        }
    }
}
//MARK: - UITextView Delegate
extension LocationDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        locationDescription = textView.text
    }
}
