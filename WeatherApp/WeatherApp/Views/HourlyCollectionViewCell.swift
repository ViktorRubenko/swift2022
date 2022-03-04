//
//  HourlyCollectionViewCell.swift
//  WeatherApp
//
//  Created by Victor Rubenko on 05.03.2022.
//

import UIKit
import SnapKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    private let hourLabel = LabelFactory.shared.centeredLabel(fontSize: 15)
    private let tempLabel = LabelFactory.shared.centeredLabel(fontSize: 15)
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.axis = .vertical
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        vStackView.addArrangedSubview(hourLabel)
        vStackView.addArrangedSubview(weatherImageView)
        vStackView.addArrangedSubview(tempLabel)
        
        contentView.addSubview(vStackView)
        
        vStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        weatherImageView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    func configure(_ data: HourlyData) {
        tempLabel.text = data.temp
        hourLabel.text = data.hour
        weatherImageView.image = UIImage(systemName: data.weatherIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
