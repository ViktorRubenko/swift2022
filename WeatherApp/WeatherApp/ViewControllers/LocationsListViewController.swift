//
//  LocationsListViewController.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import UIKit
import CoreLocation

class LocationsListViewController: UIViewController {
    
    private var tableView: UITableView!
    private var searchController: UISearchController!
    private let viewModel = LocationsListViewModel()
    private let suggestionController = LocationSuggestionsViewController()
    private var presendedController: UINavigationController?
    var completion: ((Int) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestionController.completion = { [weak self] placeName in
            self?.viewModel.findByPlaceName(placeName: placeName)
        }
        
        setupViews()
        setupBinds()
        viewModel.updateCurrentPlaceName()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.searchTextField.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }
    
    deinit {
        print("DEINIT LOCATIONS")
    }
    
    func setupBinds() {
        viewModel.placeNames.bind { [weak self] placeNames in
            self?.tableView.reloadData()
        }
        
        viewModel.temporaryLocation.bind { [weak self] location in
            if let location = location {
                self?.showSelectedForecast(self!.viewModel.temporaryPlaceName, location: location)
            }
        }
        
        viewModel.currentPlaceName.bind { [weak self] placeName in
            self?.realoadFirstCell()
        }
    }
    
    func setupNavigationBar() {
        title = NSLocalizedString("Weather", comment: "Title for NavBar")
        
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Search your city...", comment: "Search placeholder"),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

        
        navigationController?.navigationBar.prefersLargeTitles = true
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundColor = UIColor(white: 0.3, alpha: 0.75)
        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationController?.navigationBar.sizeToFit()
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func setupViews() {
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "BGColor")
        tableView.register(LocationsListCell.self, forCellReuseIdentifier: LocationsListCell.identifier)
        view.addSubview(tableView)
        
        setupNavigationBar()
    }
    
    func showSelectedForecast(_ placeName: String, location: CLLocation?) {
        guard let location = location else { return }
        print("INIT LOCATIONS")
        let vc = WeatherViewController(placeName: placeName, location: location)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(closePresented))
        vc.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "NavItemsColor")
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Add", comment: "Add location in model"),
            style: .plain,
            target: self,
            action: #selector(savePresented))
        vc.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "NavItemsColor")
        presendedController = UINavigationController(rootViewController: vc)
        present(presendedController!, animated: true, completion: nil)
    }
    
    @objc func savePresented() {
        viewModel.saveTemporary()
        searchController.searchBar.text = ""
        searchController.isActive = false
        closePresented()
    }
    
    @objc func closePresented() {
        presendedController?.dismiss(animated: true, completion: nil)
        presendedController = nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func realoadFirstCell() {
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

extension LocationsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.placeNames.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeName: String?
        if indexPath.row == 0 {
            placeName = viewModel.currentPlaceName.value
        } else {
            placeName = viewModel.placeNames.value[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationsListCell.identifier, for: indexPath) as! LocationsListCell
        cell.label.text = placeName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completion(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.remove(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.move(sourceIndexPath.row, destinationIndexPath.row)
    }
}
