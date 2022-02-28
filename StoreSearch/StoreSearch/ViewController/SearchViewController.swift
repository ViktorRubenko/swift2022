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
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false

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
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
        if searchBar.text!.isEmpty {
            return
        }
        isLoading = true
        hasSearched = true
        searchBar.resignFirstResponder()
        tableView.reloadData()
        
        let queue = DispatchQueue.global(qos: .background)
        let searchText = searchBar.text!
        queue.async { [weak self] in
            do {
                self?.searchResults = try ApiManager.shared.performStoreRequest(searchText: searchText)
                self?.isLoading = false
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            } catch {
                self?.showNetworkError()
            }
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}
