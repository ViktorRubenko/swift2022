//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit
import CoreData

class LocationsViewController: UIViewController, ManagedObjectContextProtocol {

    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        
        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sort1, sort2]

        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    var tableView: UITableView!
    private var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.rowHeight = 60
        view.addSubview(tableView)
        
        title = "Locations"
        navigationItem.rightBarButtonItem = editButtonItem
        
        performFetch()
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
}
// MARK: - Helper Methods
extension LocationsViewController {
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}
// MARK: - UITableView Delegate/DataSource
extension LocationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {

        return fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.configure(for: location)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = LocationDetailsViewController()
        let location = fetchedResultsController.object(at: indexPath)
        controller.locationToEdit = location
        controller.managedObjectContext = managedObjectContext
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            location.removePhotoFile()
            managedObjectContext.delete(location)
            do {
                try managedObjectContext.save()
            } catch {
                print("Error deliting item: \(error.localizedDescription)")
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing && !tableView.isEditing {
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem?.title = "Done"
        } else {
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 14, width: 300, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 11)
        
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.backgroundColor = .clear
        
        let separatorRect = CGRect(
            x: 15,
            y: tableView.sectionHeaderHeight - 0.5,
            width: tableView.bounds.size.width - 15,
            height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        
        let viewRect = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(separator)
        
        return view
    }
}

// MARK: - NSFetcherResultsController Delegate
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = fetchedResultsController.object(at: indexPath!)
                cell.configure(for: location)
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }
}
