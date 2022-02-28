//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Victor Rubenko on 28.02.2022.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "SearchBarColor")?.withAlphaComponent(0.5)
        
        selectedBackgroundView = backgroundView
    }
    
    func configure(searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = "\(searchResult.artist) (\(searchResult.type))"
        }
    }
    
}
