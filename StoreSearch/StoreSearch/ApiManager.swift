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
    private var currentDataTask: URLSessionDataTask?
    var isFetching = false
    
    
    private init() {}
    
    private func searchURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category{
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "\(rootURL)/search?limit=200&term=\(encodedText)&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
    }
    
    func performStoreRequest(
        searchText: String,
        category: Int,
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
