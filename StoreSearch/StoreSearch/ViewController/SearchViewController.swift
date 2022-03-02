//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 27.02.2022.
//

import UIKit


fileprivate struct Constants {
    struct CellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
}


class SearchViewController: UIViewController {
    
    var tableView: UITableView!
    var searchBar: UISearchBar!
    var segmentedControl: UISegmentedControl!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    let segmentItems = ["All", "Music", "Movie", "Software"]
    
    var landscapeVC: LandscapeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupConstraints()
        
        view.backgroundColor = .systemBackground
        
        searchBar.becomeFirstResponder()
    }
    
    private func setupSubviews() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: "SearchResultCell", bundle: nil),
            forCellReuseIdentifier: Constants.CellIdentifiers.searchResultCell)
        tableView.register(
            UINib(nibName: "NoResultsCell", bundle: nil),
            forCellReuseIdentifier: Constants.CellIdentifiers.nothingFoundCell)
        tableView.register(
            LoadingCell.self,
            forCellReuseIdentifier: Constants.CellIdentifiers.loadingCell)
        view.addSubview(tableView)
        
        searchBar = UISearchBar()
        searchBar.placeholder = "App name, artist, sone, album, e-book"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = UIColor(named: "SearchBarColor")
        view.addSubview(searchBar)
        
        segmentedControl = UISegmentedControl(items: segmentItems)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChange), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
// MARK: - Helper Methods
extension SearchViewController {
    func configureCell(_ cell: UITableViewCell, searchResult: SearchResult) {
        var config = cell.defaultContentConfiguration()
        config.text = searchResult.name
        config.secondaryText = searchResult.artistName
        cell.contentConfiguration = config
    }
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error accessing the iTunes Store. Please try again.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func performSearch() {
        if searchBar.text!.isEmpty {
            return
        }
        
        ApiManager.shared.stopCurrentRequest()
        
        isLoading = true
        hasSearched = true
        searchBar.resignFirstResponder()
        tableView.reloadData()
        
        let searchText = searchBar.text!
        let category = segmentedControl.selectedSegmentIndex
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            ApiManager.shared.performStoreRequest(searchText: searchText, category: category) { [weak self] result in
                switch result {
                case .success(let data):
                    do {
                        let result = try JSONDecoder().decode(ResultArray.self, from: data)
                        self?.searchResults = result.results
                        
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            self?.tableView.reloadData()
                        }
                    } catch {
                        print("Error decoding: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            self?.hasSearched = false
                            self?.tableView.reloadData()
                            self?.showNetworkError()
                        }
                    }
                case .failure(let error):
                    print("Error during request: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.hasSearched = false
                        self?.tableView.reloadData()
                        self?.showNetworkError()
                    }
                }
            }
        }
    }
}
// MARK: - Actions
extension SearchViewController {
    @objc func segmentChange(_ sender: UISegmentedControl) {
        performSearch()
    }
}
//MARK: - TableView Delegate/DataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }
        if searchResults.isEmpty {
            if hasSearched{
                return 1
            } else {
                return 0
            }
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.CellIdentifiers.loadingCell,
                for: indexPath) as! LoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        }
        if searchResults.isEmpty {
            return tableView.dequeueReusableCell(
                withIdentifier: Constants.CellIdentifiers.nothingFoundCell,
                for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.CellIdentifiers.searchResultCell,
            for: indexPath) as! SearchResultCell
        cell.configure(searchResult: searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.searchResult = searchResults[indexPath.row]
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        searchResults.isEmpty || isLoading ? nil : indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        searchResults.isEmpty || isLoading ? 44 : UITableView.automaticDimension
    }
}
// MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}

// MARK: - Landscape
extension SearchViewController {
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        default:
            break
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else { return }
        
        landscapeVC = LandscapeViewController()
        if let controller = landscapeVC {
            controller.searchResults = searchResults
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            }
            
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            view.addSubview(controller.view)
            addChild(controller)
            coordinator.animate(
                alongsideTransition: { _ in
                    self.searchBar.resignFirstResponder()
                    controller.view.alpha = 1
                }, completion: { _ in
                    controller.didMove(toParent: self)
                })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            coordinator.animate(
                alongsideTransition: { _ in
                    controller.view.alpha = 0
                }, completion: { _ in
                    controller.removeFromParent()
                    controller.view.removeFromSuperview()
                    self.landscapeVC = nil
                    if !self.searchResults.isEmpty {
                        self.searchBar.becomeFirstResponder()
                    }
                })
        }
    }
}
