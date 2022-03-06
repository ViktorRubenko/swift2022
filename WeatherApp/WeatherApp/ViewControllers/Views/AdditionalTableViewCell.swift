//
//  AdditionalTableViewCell.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 06.03.2022.
//

import UIKit

class AdditionalTableViewCell: UITableViewCell {
    
    static let identifier = "AdditionalTableViewCell"
    
    private let titleLabel = UILabel()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()
    private let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let margins = contentView.layoutMarginsGuide
        
        backgroundColor = UIColor(named: "SubBGColor")
        
        hStackView.addArrangedSubview(titleLabel)
        hStackView.addArrangedSubview(valueLabel)
        
        contentView.addSubview(hStackView)
        hStackView.snp.makeConstraints { make in
            make.edges.equalTo(margins.snp.edges)
        }
    }
    
    func configure(titleText: String, valueText: String) {
        titleLabel.text = titleText
        valueLabel.text = valueText
    }

}
