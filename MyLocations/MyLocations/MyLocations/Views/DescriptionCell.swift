//
//  DescriptionCell.swift
//  MyLocations
//
//  Created by Victor Rubenko on 19.02.2022.
//

import UIKit

class DescriptionCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
