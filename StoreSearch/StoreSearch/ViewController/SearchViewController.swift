//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 27.02.2022.
//

import UIKit

class SearchViewController: UIViewController {
    
    var tableView: UITableView!
    var searchBar: UISearchBar!
    
    var searchResults = [SearchResult]()
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupConstraints()
        
        view.backgroundColor = .systemBackground
    }

    private func setupSubviews() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        searchBar = UISearchBar()
        searchBar.placeholder = "App name, artist, sone, album, e-book"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
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
func configureCell(_ cell: UITableViewCell, searchResult: SearchResult) {
    var config = cell.defaultContentConfiguration()
    config.text = searchResult.name
    config.secondaryText = searchResult.artistName
    cell.contentConfiguration = config
}
//MARK: - TableView Delegate/DataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.isEmpty {
            if hasSearched {
                return 1
            } else {
                return 0
            }
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        let searchResult: SearchResult
        if searchResults.isEmpty {
            searchResult = SearchResult(name: "(Nothing found)", artistName: "")
        } else {
            searchResult = searchResults[indexPath.row]
        }
        configureCell(cell!, searchResult: searchResult)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        searchResults.isEmpty ? nil : indexPath
    }
}
// MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hasSearched = true
        searchResults = []
        for i in 0...2 {
            searchResults.append(SearchResult(name: "Fake result \(i)", artistName: searchBar.text!))
        }
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }
}
