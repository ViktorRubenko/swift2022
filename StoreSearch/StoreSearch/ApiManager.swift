//
//  ApiManager.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 28.02.2022.
//

import Foundation


enum Category: Int {
    case all = 0
    case music = 1
    case movie = 3
    case software = 2
}

class ApiManager {
    
    static let shared = ApiManager()
    private let rootURL = "https://itunes.apple.com"
    private var currentDataTask: URLSessionDataTask?
    var isFetching = false
    
    private init() {}
    
    private func searchURL(searchText: String, category: Category) -> URL {
        let kind: String
        switch category {
        case .all:
            kind = ""
        case .music:
            kind = "musicTrack"
        case .movie:
            kind = "software"
        case .software:
            kind = "movie"
        }
        
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let language = Locale.autoupdatingCurrent.identifier
        let countryCode = Locale.autoupdatingCurrent.regionCode ?? "en_US"
        let urlString = "\(rootURL)/search?limit=200&term=\(encodedText)" + "&entity=\(kind)&lang=\(language)&country=\(countryCode)"
        let url = URL(string: urlString)
        return url!
    }
    
    func performStoreRequest(
        searchText: String,
        category: Category,
        complitionHandler: @escaping ((Result<Data, Error>)->Void)) {
            let url = searchURL(searchText: searchText, category: category)
            let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    if let error = error as NSError?, error.code == -999 {
                        // canceled
                        return
                    }
                    complitionHandler(.failure(error))
                }
                if let data = data {
                    complitionHandler(.success(data))
                }
                self.isFetching = false
                self.currentDataTask = nil
            }
            currentDataTask = dataTask
            isFetching = true
            dataTask.resume()
        }
    
    func stopCurrentRequest() {
        if isFetching, let dataTask = currentDataTask {
            dataTask.cancel()
            isFetching = false
        }
    }
}
