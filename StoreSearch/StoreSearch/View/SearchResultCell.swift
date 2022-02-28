//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 28.02.2022.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var artworkImageView: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "SearchBarColor")?.withAlphaComponent(0.5)
        
        selectedBackgroundView = backgroundView
    }
    
    override func prepareForReuse() {
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    func configure(searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = "\(searchResult.artist) (\(searchResult.type))"
        }
        artworkImageView.image = UIImage(systemName: "square")
        if let smallURL = URL(string: searchResult.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
    
}
