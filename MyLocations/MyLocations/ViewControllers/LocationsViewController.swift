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
    
    var tableView: UITableView!
    private var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = Location.entity()
        
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UITableView Delegate/DataSource
extension LocationsViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        print("sections", fetchedResultsController.sections!.count)
//        return fetchedResultsController.sections!.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let sectionInfo = fetchedResultsController.sections![section]
//        return sectionInfo.name
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let location = locations[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = location.locationDescription
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = LocationDetailsViewController()
        controller.managedObjectContext = managedObjectContext
        controller.locationToEdit = locations[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - NSFetcherResultsController Delegate
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
}
