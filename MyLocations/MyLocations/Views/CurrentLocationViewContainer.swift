//
//  CurrentLocationViewContainer.swift
//  MyLocations
//
//  Created by Victor Rubenko on 24.02.2022.
//

import UIKit

class CurrentLocationViewContainer: UIView {

    let messageLabel = labelFactory(text: "(Message goes here)", textColor: .systemGray, alignment: .center)
    let latitudeLabel = labelFactory(text: "Latitude:", textColor: .systemGray)
    let longitudeLabel = labelFactory(text: "Longitude:", textColor: .systemGray)
    let latitudeValueLabel = labelFactory(text: "(Latitude goes here)", alignment: .right, fontSize: 20)
    let longitudeValueLabel = labelFactory(text: "(Longitude goes here)", alignment: .right, fontSize: 20)
    let addressLabel = labelFactory(text: "(Address goes here)", textColor: .systemGray, alignment: .center, numberOfLines: 0)
    
    let tagButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tag Location", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(messageLabel)
        addSubview(latitudeLabel)
        addSubview(longitudeLabel)
        addSubview(latitudeValueLabel)
        addSubview(longitudeValueLabel)
        addSubview(addressLabel)
        addSubview(tagButton)
        
        self.backgroundColor = .red
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: self.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: latitudeValueLabel.topAnchor, constant: -24),
            
            latitudeValueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            latitudeValueLabel.bottomAnchor.constraint(equalTo: longitudeValueLabel.topAnchor, constant: -8),
            latitudeValueLabel.leadingAnchor.constraint(equalTo: longitudeValueLabel.leadingAnchor),
            
            longitudeValueLabel.trailingAnchor.constraint(equalTo: latitudeValueLabel.trailingAnchor),
            longitudeValueLabel.leadingAnchor.constraint(equalTo: longitudeLabel.trailingAnchor, constant: 16),
            
            latitudeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            latitudeLabel.centerYAnchor.constraint(equalTo: latitudeValueLabel.centerYAnchor),
            
            longitudeLabel.leadingAnchor.constraint(equalTo: latitudeLabel.leadingAnchor),
            longitudeLabel.centerYAnchor.constraint(equalTo: longitudeValueLabel.centerYAnchor),
            
            addressLabel.topAnchor.constraint(equalTo: longitudeValueLabel.bottomAnchor, constant: 24),
            addressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            tagButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 24),
            tagButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tagButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
