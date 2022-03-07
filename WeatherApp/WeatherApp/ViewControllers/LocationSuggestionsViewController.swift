//
//  LocationSuggestionsViewController.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import UIKit
import MapKit

class LocationSuggestionsViewController: UITableViewController {
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    var completion: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        tableView.backgroundColor = UIColor(named: "BGColor")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = searchResults[indexPath.row]
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        var config = cell.defaultContentConfiguration()
        config.attributedText = NSAttributedString(
            string: result.title,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
            ])
        cell.contentConfiguration = config
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        35
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completion?(searchResults[indexPath.row].title)
    }
}

extension LocationSuggestionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchCompleter.queryFragment = searchController.searchBar.text!
        tableView.reloadData()
    }
}

extension LocationSuggestionsViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results.filter( {
            $0.title.rangeOfCharacter(from: .decimalDigits) == nil && $0.subtitle.rangeOfCharacter(from: .decimalDigits) == nil
        })
        tableView.reloadData()
    }
}
