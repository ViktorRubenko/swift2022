//
//  TwoLabelsCell.swift
//  MyLocations
//
//  Created by Victor Rubenko on 19.02.2022.
//

import UIKit

class TwoLabelsCell: UITableViewCell {

    var leftLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "Left"
        return label
    }()
    var rightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.text = "Right"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        return stackView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        labelsStackView.addArrangedSubview(leftLabel)
        labelsStackView.addArrangedSubview(rightLabel)
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(labelsStackView)
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
