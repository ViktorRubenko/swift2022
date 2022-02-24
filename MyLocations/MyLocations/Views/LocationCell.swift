//
//  LocationCell.swift
//  MyLocations
//
//  Created by Victor Rubenko on 24.02.2022.
//

import UIKit

class LocationCell: UITableViewCell {
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(12)
        label.textColor = .systemGray
        return label
    }()
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let imageSize: CGFloat = 50.0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textStackView.addArrangedSubview(mainLabel)
        textStackView.addArrangedSubview(subLabel)
        
        contentView.addSubview(photoImageView)
        contentView.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: imageSize),
            
            textStackView.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for location: Location) {
        mainLabel.text = location.locationDescription
        if let thoroughfare = location.placemark?.thoroughfare {
            subLabel.text = thoroughfare + ", "
        }
        if let subThoroughfare = location.placemark?.subThoroughfare{
            subLabel.text = subLabel.text ?? "" + subThoroughfare
        }
        if location.hasPhoto {
            photoImageView.image = location.photoImage!.resized(withBounds: CGSize(width: imageSize, height: imageSize))
        }
    }
}
