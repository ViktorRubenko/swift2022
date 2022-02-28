//
//  ApiManager.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 28.02.2022.
//

import Foundation


class ApiManager {
    
    static let shared = ApiManager()
    private let rootURL = "https://itunes.apple.com"
    
    private init() {}
    
    private func searchURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "\(rootURL)/search?term=\(encodedText)"
        let url = URL(string: urlString)
        return url!
    }
    
    private func fetchRequest(with url: URL) throws -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Downloading Error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func performStoreRequest(searchText: String) throws -> [SearchResult] {
        do {
            if let data = try fetchRequest(with: searchURL(searchText: searchText)) {
                let result = try JSONDecoder().decode(ResultArray.self, from: data)
                return result.results
            } else {
                return []
            }
        } catch {
            throw error
        }
    }
}
