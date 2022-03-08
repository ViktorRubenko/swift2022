//
//  LocationsListCell.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 07.03.2022.
//

import UIKit

class LocationsListCell: UITableViewCell {
    
    static let identifier = "LocationsListCell"

    let label = LabelFactory.shared.centeredLabel(fontSize: 25)
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        label.textColor = .white
        containerView.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        containerView.layer.cornerRadius = 10
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }

}
