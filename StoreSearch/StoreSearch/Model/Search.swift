//
//  Search.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 03.03.2022.
//

import Foundation

class Search {
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    private (set) var state: State = .notSearchedYet
    
    func performSearch(searchText: String, category: Category, complitionHandler: @escaping ((Bool) -> Void)) {
        ApiManager.shared.stopCurrentRequest()
        
        state = .loading
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            ApiManager.shared.performStoreRequest(
                searchText: searchText,
                category: category) {[weak self] result in
                    switch result {
                    case .success(let data):
                        do {
                            let result = try JSONDecoder().decode(ResultArray.self, from: data)
                            if !result.results.isEmpty {
                                self?.state = .results(result.results)
                            } else {
                                self?.state = .noResults
                            }
                            complitionHandler(true)
                        } catch {
                            print("Error decoding: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self?.state = .notSearchedYet
                                complitionHandler(false)
                            }
                        }
                    case .failure(let error):
                        print("Error during request: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.state = .notSearchedYet
                            complitionHandler(false)
                        }
                    }
                }
        }
    }
}
