//
//  DailyTableViewCell.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 05.03.2022.
//

import UIKit
import SnapKit

class DailyTableViewCell: UITableViewCell {

    private let dayLabel = UILabel()
    private let maxTempLabel = UILabel()
    private let minTempLabel = UILabel()
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor(named: "SubBGColor")
        setupViews()
    }
    
    private func setupViews() {
        minTempLabel.textAlignment = .right
        maxTempLabel.textAlignment = .right
        
        hStackView.addArrangedSubview(dayLabel)
        hStackView.addArrangedSubview(weatherImageView)
        hStackView.addArrangedSubview(minTempLabel)
        hStackView.addArrangedSubview(maxTempLabel)
        
        contentView.addSubview(hStackView)
        
        hStackView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide.snp.edges)
        }
    }
    
    func configure(_ data: DailyData) {
        dayLabel.text = data.day
        maxTempLabel.text = data.maxTemp
        minTempLabel.text = data.minTemp
        weatherImageView.image = UIImage(systemName: data.weatherIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
