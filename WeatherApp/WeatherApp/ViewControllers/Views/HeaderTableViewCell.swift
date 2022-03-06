//
//  HeaderTableViewCell.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    static let identifier = "HeaderTableViewCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(named: "HeaderLabelColor")
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = UIColor(named: "SubBGColor")
        
        contentView.addSubview(titleLabel)
        
        let margins = contentView.layoutMarginsGuide
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(margins.snp.edges)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
