//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 28.02.2022.
//

import Foundation


struct ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

struct SearchResult: Codable {
    var trackName: String?
    var artistName: String?
    var kind: String?
    var trackPrice: Double?
    var currency: String
    var imageSmall: String
    var imageLarge: String
    var trackViewUrl: String?
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    var primaryGenreName: String?
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case bookGenre = "genres"
        case itemPrice = "price"
        
        case kind, artistName, currency
        case trackPrice, trackViewUrl, trackName
        case collectionName, collectionPrice, collectionViewUrl
        case primaryGenreName
    }
    
    var name: String {
        trackName ?? collectionName ?? " "
    }
    
    var price: Double{
        trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var storeURL: String {
        trackViewUrl ?? collectionViewUrl ?? " "
    }
    
    var genre: String {
        if let genre = primaryGenreName {
            return genre
        }
        if let genre = itemGenre {
            return genre
        }
        if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return " "
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        
        switch kind {
        case "album": return NSLocalizedString("Album", comment: "Localized kind: Album")
        case "audiobook": return NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book")
        case "book": return NSLocalizedString("Book", comment: "Localized kind: Book")
        case "ebook": return NSLocalizedString("E-Book", comment: "Localized kind: E-Book")
        case "feature-movie": return NSLocalizedString("Movie", comment: "Localized kind: Movie")
        case "music-video": return NSLocalizedString("Music Video", comment: "Localized kind: Music Video")
        case "podcast": return NSLocalizedString("Podcast", comment: "Localized kind: Podcast")
        case "software": return NSLocalizedString("App", comment: "Localized kind: App")
        case "song": return NSLocalizedString("Song", comment: "Localized kind: Song")
        case "tv-episode": return NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
        default: break
        }
        return "Unknown"
    }
    
    var artist: String {
        artistName ?? " "
    }
}

extension SearchResult: CustomStringConvertible {
    var description: String {
        "\nResult - Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")"
    }
}

extension SearchResult {
    static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.name.localizedCompare(rhs.name) == .orderedAscending
    }
}
