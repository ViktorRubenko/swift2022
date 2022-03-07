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
    private let viewModel = LocationsViewModel()
    private var locations = [WeatherLocation?]()
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
        
        viewModel.loadLocations()
    }
    
    deinit {
        print("DEINIT LOCATIONS")
    }
    
    func setupBinds() {
        viewModel.locations.bind { [weak self] locations in
            self?.locations = locations
            self?.tableView.reloadData()
            print("LOCATIONS UPDATE")
        }
        
        viewModel.temporaryLocation.bind { [weak self] location in
            if let location = location {
                self?.showSelectedForecast(self!.viewModel.temporaryPlaceName, location: location)
            }
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
        standardAppearance.backgroundColor = UIColor(white: 0.3, alpha: 0.25)
        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        standardAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationController?.navigationBar.sizeToFit()
    }
    
    func setupViews() {
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "BGColor")
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
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Add", comment: "Add location in model"),
            style: .plain,
            target: self,
            action: #selector(savePresented))
        presendedController = UINavigationController(rootViewController: vc)
        present(presendedController!, animated: true, completion: nil)
    }
    
    @objc func savePresented() {
        viewModel.saveTemporary()
        searchController.searchBar.text = ""
        closePresented()
    }
    
    @objc func closePresented() {
        presendedController?.dismiss(animated: true, completion: nil)
        presendedController = nil
    }
}

extension LocationsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherLocation = locations[indexPath.row]
        let cell = UITableViewCell()
        var config = cell.defaultContentConfiguration()
        config.text = weatherLocation?.placeName
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completion(indexPath.row)
    }
}
