//
//  AddressCell.swift
//  MyLocations
//
//  Created by Victor Rubenko on 23.02.2022.
//

import UIKit

class AddressCell: TwoLabelsCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        rightLabel.font = rightLabel.font.withSize(12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
