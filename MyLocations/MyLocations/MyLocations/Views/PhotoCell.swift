//
//  PhotoCell.swift
//  MyLocations
//
//  Created by Victor Rubenko on 22.02.2022.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    var leftLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    var photoImage: UIImage? {
        didSet {
            if let image = photoImage {
                photoImageView.image = image
                photoImageView.isHidden = false
            } else {
                photoImageView.image = nil
                photoImageView.isHidden = true
            }
        }
    }
    var photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var imageHeight: NSLayoutConstraint!
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        photoImageView.isHidden = true
        imageHeight = photoImageView.heightAnchor.constraint(equalToConstant: 24)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(photoImageView)
        contentView.addSubview(leftLabel)
        NSLayoutConstraint.activate([
            leftLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            leftLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            leftLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            photoImageView.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: 10),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageHeight
        ])
        
    }
}
