//
//  MainTableViewCell.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 04.03.2022.
//

import UIKit
import SnapKit

class MainTableViewCell: UITableViewCell {
    
    let placeLabel = LabelFactory.shared.centeredLabel(fontSize: 30)
    let weatherDescriptionLabel = LabelFactory.shared.centeredLabel(fontSize: 18)
    let tempLabel = LabelFactory.shared.centeredLabel(fontSize: 80)
    let tempDetailsLabel = LabelFactory.shared.centeredLabel(fontSize: 15)
    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        return stackView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubviews()
    }
    
    private func setupSubviews() {
        placeLabel.adjustsFontSizeToFitWidth = true
        placeLabel.minimumScaleFactor = 0.1
        
        tempLabel.adjustsFontSizeToFitWidth = true
        tempLabel.minimumScaleFactor = 0.1
        
        vStackView.addArrangedSubview(placeLabel)
        vStackView.addArrangedSubview(weatherDescriptionLabel)
        vStackView.addArrangedSubview(tempLabel)
        vStackView.addArrangedSubview(tempDetailsLabel)
        vStackView.addArrangedSubview(weatherImageView)
        
        contentView.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
        weatherImageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.33)
            make.height.equalTo(weatherImageView.snp.width)
        }
    }
    
    func configure(placeName: String, weatherData: WeatherData?) {
        placeLabel.text = placeName
        if let weatherData = weatherData {
            weatherDescriptionLabel.text = weatherData.weatherDescription
            tempDetailsLabel.text = weatherData.tempDetails
            tempLabel.text = weatherData.temp
            weatherImageView.image = UIImage(systemName: weatherData.weatherIcon)
        }
    }
}
