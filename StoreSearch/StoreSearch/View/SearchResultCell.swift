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
//        artworkImageView.image = searchResult.artworkImage
        nameLabel.text = searchResult.name
        artistNameLabel.text = searchResult.artistName
    }
    
}
